[CCode (cname = "gen_timestamp", cheader_filename = "gen_timestamp.h")]
string gen_timestamp(string format,time_t time);

[CCode (cname = "strcasecmp", cheader_filename = "string.h")]
int strcasecmp(string s1,string s2);

#if WINDOWS
void open_url_in_browser(string url);
#endif

//[CCode (cprefix = "", lower_case_cprefix = "", cheader_filename = "config.h")]
//namespace XSIRC {
	public const string PACKAGE_NAME;
	public const string APPNAME;
	public const string VERSION;
	public const string GETTEXT_PACKAGE;
	public const string LOCALE_DIR;
	public const string OS;
	public const string PREFIX;
//}
