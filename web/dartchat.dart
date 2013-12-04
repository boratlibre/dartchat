import 'dart:convert';
import 'dart:html';

void main() {
  /*
   * This WebSocket is different from the server WebSocket.
   * This one is in dart:html package
   * The server one is in dart:io package
   */
  var ws = new WebSocket('ws://127.0.0.1:8080');

  ws.onMessage.listen((MessageEvent e){
    var obj=JSON.decode(e.data);
    switch(obj['cmd']){
      case 'list':
        querySelector('#users').setInnerHtml(obj['v'].join('<br/>')+'<br/>');
        querySelector('#board').scrollByLines(obj['v'].length);
        break;
      case 'chat':
        querySelector('#board').appendHtml(obj['v'] +'<br/>');
        querySelector('#board').scrollByLines(1);
        break;
    }
  });

  /**
   * Add keyboard listener
   * Auto send when enter key is pressed
   */
  querySelector('#message').onKeyDown.listen((e){
    if(e.keyCode==13){
      ws.send(JSON.encode({'cmd':'chat','v':e.target.value}));
      e.target.value="";
    }
  });
}