/*
 * macromanager.vala
 *
 * Copyright (c) 2010 Eduardo Niehues
 * Distributed under the New BSD License; see ../LICENSE for details.
 */
using Gee;
namespace XSIRC {
	public class MacroManager : Object {
		public class PrefWindow : Object {
			private Gtk.Dialog window;
			private Gtk.TreeView macro_tree;
			private Gtk.ListStore macro_model;
			
			private enum MacroColumns {
				REGEX,
				RESULT,
				N_COLUMNS
			}
			
			public PrefWindow() {
				window = new Gtk.Dialog.with_buttons("Macros",Main.gui.main_window,Gtk.DialogFlags.MODAL,Gtk.STOCK_CLOSE,0,null);
				
				macro_model = new Gtk.ListStore(MacroColumns.N_COLUMNS,typeof(string),typeof(string));
				macro_tree = new Gtk.TreeView.with_model(macro_model);
				
				Gtk.CellRendererText regex_renderer = new Gtk.CellRendererText();
				regex_renderer.editable = true;
				regex_renderer.edited.connect(regex_edited);
				macro_tree.append_column(new Gtk.TreeViewColumn.with_attributes("Regex",regex_renderer,"text",MacroColumns.REGEX,null));
				
				Gtk.CellRendererText result_renderer = new Gtk.CellRendererText();
				result_renderer.editable = true;
				result_renderer.edited.connect(result_edited);
				macro_tree.append_column(new Gtk.TreeViewColumn.with_attributes("Result",result_renderer,"text",MacroColumns.RESULT,null));
				
				Gtk.ScrolledWindow scroll = new Gtk.ScrolledWindow(null,null);
				scroll.add(macro_tree);
				window.vbox.pack_start(scroll,true,true,0);
				
				Gtk.HButtonBox bbox = new Gtk.HButtonBox();
				window.vbox.pack_start(bbox,false,true,0);
				Gtk.Button add_button = new Gtk.Button.from_stock(Gtk.STOCK_ADD);
				bbox.pack_start(add_button,true,true,0);
				add_button.clicked.connect(add_macro);
				Gtk.Button remove_button = new Gtk.Button.from_stock(Gtk.STOCK_REMOVE);
				remove_button.clicked.connect(remove_macro);
				bbox.pack_start(remove_button,true,true,0);
				
				load_macros();
				
				window.response.connect(() => {
					window.destroy();
					Main.gui.destroy_macro_prefs_window();
				});
				window.show_all();
			}
			
			private void add_macro() {
				
			}
			
			private void remove_macro() {
				
			}
			
			private void regex_edited(string path,string new_text) {
				
			}
			
			private void result_edited(string path,string new_text) {
				
			}
			
			private void load_macros() {
				macro_model.clear();
				Gtk.TreeIter iter;
				foreach(Macro macro in Main.macro_manager.macros) {
					macro_model.append(out iter);
					macro_model.set(iter,MacroColumns.REGEX,macro.regex,MacroColumns.RESULT,macro.result);
				}
			}
		}
		public struct Macro {
			public string regex;
			public string result;
		}
		public LinkedList<Macro?> macros = new LinkedList<Macro?>();
		private KeyFile macros_file;
		private const Macro[] default_macros = {
			{"^me (.+)$","PRIVMSG $CURR_VIEW :ACTION $1"},
			{"^ctcp ([^ ]+) ([^ ]+) (.+)$","PRIVMSG $1 :$2 $3"},
			{"^ctcp ([^ ]+) ([^ ]+)$","PRIVMSG $1 :$2"},
			{"^msg ([^ ]+) (.+)$","PRIVMSG $1 :$2"},
			{"^notice ([^ ]+) (.+)$","NOTICE $1 :$2"},
			{"^part$","PART $CURR_VIEW"},
			{"^part (#[^ ]+)$","PART $1"},
			{"^part (#[^ ]+) (.+)$","PART $1 :$2"},
			{"^kick ([^ ]+)$","KICK $CURR_VIEW $1"},
			{"^kick ([^ ]+) (.+)$","KICK $CURR_VIEW $1 :$2"},
			{"^quit (.+)$","QUIT :$1"},
			{"^topic$","TOPIC $CURR_VIEW"},
			{"^topic (.+)$","TOPIC $CURR_VIEW :$1"},
			{"^mode$","MODE $CURR_VIEW"}
		};
		
		public MacroManager() {
			load_macros();
		}
		
		private void load_macros() {
			macros_file = new KeyFile();
			try {
				macros_file.load_from_file(Environment.get_user_config_dir()+"/xsirc/macros.conf",0);
			} catch(KeyFileError e) {
				Gtk.MessageDialog d = new Gtk.MessageDialog(Main.gui.main_window,Gtk.DialogFlags.MODAL,Gtk.MessageType.ERROR,Gtk.ButtonsType.CLOSE,"Could not parse the macros file. Loading default macros.");
				d.response.connect((id) => {
					d.destroy();
				});
				d.run();
				load_default_macros();
				return;
			} catch(FileError e) {
				stderr.printf("Could not open macros.conf: %s\n",e.message);
				load_default_macros();
				return;
			}
			string k;
			string v;
			try {
				for(int i = 0; macros_file.has_key("macros","regex%d".printf(i)) && macros_file.has_key("macros","result%d".printf(i)); i++) {
					k = macros_file.get_string("macros","regex%d".printf(i));
					v = macros_file.get_string("macros","result%d".printf(i));
					Macro macro = Macro();
					try {
						// Testing if it compiles
						Regex test =  new Regex(k);
						macro.regex = k;
					} catch(RegexError e) {
						continue;
					}
					macro.result = v;
					macros.add(macro);
				}
			} catch(KeyFileError e) {
				
			}
		}
		
		private void load_default_macros() {
			foreach(Macro macro in default_macros) {
				macros.add(macro);
			}
		}
		
		public string? parse_string(string testee) {
			foreach(Macro macro in macros) {
				try {
					Regex regex = new Regex(macro.regex);
					MatchInfo info;
					if(regex.match(testee,0,out info)) {
						string result = macro.result;
						for(int i = 1; i <= 9 && i <= info.get_match_count(); i++) {
							if(info.fetch(i) != null) {
								result = (result.replace("$%d".printf(i),info.fetch(i)) ?? result);
							}
						}
						if(Main.gui.current_server() != null && Main.gui.current_server().current_view() != null) {
							result = (result.replace("$CURR_VIEW",Main.gui.current_server().current_view().name) ?? result);
						}
						return result;
					}
				} catch(RegexError e) {
					
				}
			}
			return null;
		}
		
		public void save_macros() {
			macros_file = new KeyFile();
			int i = 0;
			foreach(Macro macro in macros) {
				try {
					macros_file.set_string("macros","regex%d".printf(i),macro.regex);
					macros_file.set_string("macros","result%d".printf(i),macro.result);
				} catch(KeyFileError e) {
					
				}
				i++;
			}
			try {
				FileUtils.set_contents(Environment.get_user_config_dir()+"/xsirc/macros.conf",macros_file.to_data());
			} catch(Error e) {
				stderr.printf("Could not save macros file.\n");
			}
		}
	}
}