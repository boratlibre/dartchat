import 'dart:async';
import 'dart:convert';
import 'dart:io';

/**
 * Keep track of which [WebSocket] belongs to which [User]
 */
Map users=new Map<WebSocket,User>();
/**
 * A number to keep the user's name different;
 */
int user_counter=1;
void main() {
  int port = 8080;

  /**
   * Create a HttpServer. We need to borrow the bind function to listen for incoming connections.
   * When the server receives a request, use the [WebSocketTransfomer] class to transform it
   * into a WebsoketStream.
   *
   * The [WebSocketTransfomer] can only transform websocket requests. If the user sends a normal
   * HTTP request, the transformer will fail. We need to catch it
   *
   */

  HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port).then((request) {
    print('Server started');
    /**
     *
     * When the HttpServer is listening (through bind), whenever a user calls the server
     * the server generate a request, thus a stream of requests.
     *
     * The request stream is converted into a websocket stream via WebSocketTransfomer.
     * The listen function is generic too all steams. The first function onData(T), T is an instance of [WebSocket]
     * The <T> will be different for the listen function in handleWebSocket function.
     */
    request.transform(new WebSocketTransformer()).listen(socketCreated,
        onError:(Error e){
          print("Error : ${e.toString()}");
          }
        );
  });

}


/**
 * Handle an established [WebSocket] connection.
 */
void socketCreated(WebSocket ws) {

  /**
   * Listen for [WebSocket] stream.
   * It's a steam of messages(Strings).
   * The first function of listn, onData(T), T is messages(Strings) coming in
   * from the WebSocket. Please refer to the previous listen function and compare
   * the differences.
   *
   * The messages comes in as {'cmd':'the command', 'v':'value passing in'}
   */
  ws.listen(
    (String message){
      var obj=JSON.decode(message);
      switch(obj['cmd']){
        case 'nickname':
          setNickname(obj['v'],ws);
          updateUserList();
          break;
        case 'chat':
          broadcastMessage(obj['v'],ws);
          break;
      }
    }, onDone:(){
      /**
       * Remove the user from the listing
       */
      users.remove(ws);
      updateUserList();
    }, onError:(Error e){
      print("Error: ${e.toString()}");
  });

  /**
   * Create a new User instance to pair with the WebSocket
   */
  User u=new User();
  users[ws]=u;

  updateUserList();
}

/**
 * broadcast the list of users
 */
void updateUserList(){
  List<String> names=new List<String>();
  users.forEach((k,v)=>names.add(v.nickname));
  String obj=JSON.encode({'cmd':'list','v':names});
  users.forEach((k,v)=>k.add(obj));
}

/**
 * Send the message to everyone other than the user himself/herself
 */
void broadcastMessage(String message, WebSocket ws){
  String obj=JSON.encode({'cmd':'chat','v':"${users[ws].nickname}: $message"});
  users.forEach((k,v){k.add(obj);});
}

/**
 * Set the user's nickname
 */
void setNickname(String name, WebSocket ws){
  users[ws].nickname=name;
}

/**
 * User class
 * Now it only has a nickname attribute.
 * You can expand it to have attributes like
 * which chat room he/she is in
 * if the user is moderator
 * etc.
 */
class User{
  String nickname;
  User(){

    nickname="u-${user_counter++}";
  }
}