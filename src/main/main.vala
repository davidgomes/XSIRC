using Gee;
using XSIRC;

private int main (string[] args) {
    Gtk.init (ref args);
    Intl.textdomain (GETTEXT_PACKAGE);
    Intl.bindtextdomain (GETTEXT_PACKAGE,LOCALE_DIR);
    Environment.set_application_name (GETTEXT_PACKAGE);

    try {
        Gtk.Window.set_default_icon (new Gdk.Pixbuf.from_file (get_icon_path()));
    } catch (Error e) {

    }

    /* Set up some folder structure for stuff */
    if (!FileUtils.test (Environment.get_user_config_dir () + "/xsirc", FileTest.EXISTS)) {
        DirUtils.create (Environment.get_user_config_dir () + "/xsirc", 0755);
        DirUtils.create (Environment.get_user_config_dir () + "/xsirc/plugins", 0755);
    }

    /* Set up configuration */
    Main.config_manager = new ConfigManager ();
    Main.config_file = Main.config_manager.config;
    Main.config = new ConfigManager.ConfigAccessor ();
    
    /* Log folder */
    if (!FileUtils.test (Main.config.string["log_folder"], FileTest.EXISTS)) {
        DirUtils.create (Main.config.string["log_folder"], 0755);
    }
    
    Main.server_manager = new ServerManager();
    Main.macro_manager = new MacroManager ();
    MIRCParser.mirc_colors = new HashMap<int,string> ();

    /* Set up palette */
    MIRCParser.mirc_colors[0] = "#cccccccccccc"; // white
    MIRCParser.mirc_colors[1] = "#000000000000"; // black
    MIRCParser.mirc_colors[2] = "#35c235c2b332"; // dark blue
    MIRCParser.mirc_colors[3] = "#2a3d8ccc2a3d"; // green
    MIRCParser.mirc_colors[4] = "#c3c33b3b3b3b"; // red
    MIRCParser.mirc_colors[5] = "#c7c732323232"; // light red
    MIRCParser.mirc_colors[6] = "#800026667fff"; // purple
    MIRCParser.mirc_colors[7] = "#666636361f1f"; // orange
    MIRCParser.mirc_colors[8] = "#d999a6d34147"; // yellow
    MIRCParser.mirc_colors[9] = "#3d70cccc3d70"; // light green
    MIRCParser.mirc_colors[10] = "#199a55555555"; // aqua
    MIRCParser.mirc_colors[11] = "#2eef8ccc74df"; // light aqua
    MIRCParser.mirc_colors[12] = "#451e451ee666"; // blue
    MIRCParser.mirc_colors[13] = "#b0b03737b0b0"; // light purple
    MIRCParser.mirc_colors[14] = "#4c4c4c4c4c4c"; // grey
    MIRCParser.mirc_colors[15] = "#959595959595"; // light grey
    
    Main.plugin_manager = new PluginManager ();
    
    Main.gui = new XSIRC.GUI ();
    Main.gui.startup();
    Main.plugin_manager.startup ();
    Main.server_manager.startup ();
    Main.plugin_manager.on_startup ();
    
    Gtk.main ();
    Main.plugin_manager.on_shutdown ();
    Main.server_manager.shutdown ();
    
    return 0;
}
