
// *** request sample ***
// mass:werk, N.Landsteiner 2007

var term;

var help = [
'       =[ metasploit v3.7.0-dev [core:3.7 api:1.0]',
'+ -- --=[ 675 exploits - 352 auxiliary',
'+ -- --=[ 219 payloads - 27 encoders - 8 nops',

];

function termOpen() {
	if ((!term) || (term.closed)) {
		term = new Terminal(
			{
				termDiv: 'termDiv',
				greeting: help.join('\n'),
				handler: termHandler,
        ps: "msf >",
				exitHandler: termExitHandler
			}
		);
		term.open();

		// dimm UI text
		var mainPane = (document.getElementById)?
			document.getElementById('mainPane') : document.all.mainPane;
		if (mainPane) mainPane.className = 'lh15 dimmed';
	}
}

function termExitHandler() {
	// reset the UI
	var mainPane = (document.getElementById)?
		document.getElementById('mainPane') : document.all.mainPane;
	if (mainPane) mainPane.className = 'lh15';
}

function pasteCommand(text) {
	// insert given text into the command line and execute
	var termRef = TermGlobals.activeTerm;
	if ((!termRef) || (termRef.closed)) {
		alert('Please open the terminal first.');
		return;
	}
	if ((TermGlobals.keylock) || (termRef.lock)) return;
	termRef.cursorOff();
	termRef._clearLine();
	for (var i=0; i<text.length; i++) {
		TermGlobals.keyHandler({which: text.charCodeAt(i), _remapped:true});
	}
	TermGlobals.keyHandler({which: termKey.CR, _remapped:true});
}

function termHandler() {
	this.newLine();
  //this.ps = "onkel";
	this.lineBuffer = this.lineBuffer.replace(/^\s+/, '');
	var argv = this.lineBuffer.split(/\s+/);
	var cmd = argv;
    jQuery.ajax('/console/input',
    {type:'post',data: 'cmd='+this.lineBuffer});

	this.prompt();
}

function myServerCallback() {
	var response=this.socket;
	if (response.success) {
		var func=null;
		try {
			func=eval(response.responseText);
		}
		catch (e) {
		}
		if (typeof func=='function') {
			try {
				func.apply(this);
			}
			catch(e) {
				this.write('An error occured within the imported function: '+e);
			}
		}
		else {
			this.write('Server Response:\n' + response.responseText);
		}
		this.newLine();
		this.write('Response Statistics:');
		this.newLine();
		this.write('  Content-Type: ' + response.headers.contentType);
		this.newLine();
		this.write('  Content-Length: ' + response.headers.contentLength);
	}
	else {
		var s='Request failed: ' + response.status + ' ' + response.statusText;
		if (response.errno) s +=  '\n' + response.errstring;
		this.write(s);
	}
	this.prompt();
}
