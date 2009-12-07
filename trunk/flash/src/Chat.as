package src{
	import flash.net.*;
	import flash.events.*;
	import flash.display.*;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import fl.controls.TextArea;
	import flash.external.ExternalInterface;
	import fl.data.DataProvider;
	
	public class Chat extends Sprite {
		
		private var nc:NetConnection;
		private var listSO:SharedObject;
		private var msgSO:SharedObject;
		private var userArr:Array;
		private var now:Date = new Date();
		/*
		private var res:Responder;
		*/
		
		private var everyBody:String = "Everybody";
		//private var path:String = "rtmp://172.20.204.40/chatApp";//local
		private var path:String = "rtmp://172.16.9.127/chatApp";//server
		
		public function Chat():void{
			init();
		}
		private function init():void{
			stage.showDefaultContextMenu = false;
			testTxt.text = path;
			
			sendBtn.label = "send";
			coBtn.label = "connect";
			closeBtn.label = "close";
			sendBtn.useHandCursor = true;
			coBtn.useHandCursor = true;
			closeBtn.useHandCursor = true;
			closeBtn.enabled = false;
			sendBtn.enabled = false;
			
			history.editable = false; 
			txt.text = "disconnect";
			
			coBtn.addEventListener(MouseEvent.CLICK, connect);
			sendBtn.addEventListener(MouseEvent.CLICK, sendBtnHandler);
			closeBtn.addEventListener(MouseEvent.CLICK, closeBtnHandler);
			
		}
		
		//connect
		private function connect(event:MouseEvent):void{
			if(userName.text!=""){
				nc = new NetConnection();
				nc.connect(testTxt.text,userName.text);
				nc.client = this;
				nc.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				/*
				res=new Responder(login_Result,login_Fault);
				*/
			}else{
				txt.text = "请先输入您的名字！";
			}
			
		}
		private function netStatusHandler(event:NetStatusEvent):void {
			switch (event.info.code) {
				case "NetConnection.Connect.Success" :
					txt.text = "连接成功";
					coBtn.enabled = false;
					closeBtn.enabled = true;
					sendBtn.enabled = true;
					setListSO();
					setMsgSO();
					testTxt.type = TextFieldType.DYNAMIC;
					break;
				case "NetConnection.Connect.Rejected" :
					txt.text = "连接被拒绝";
					break;
				case "NetConnection.Connect.Failed" :
					txt.text = "连接失败";
					break;
				case "NetConnection.Connect.Closed" :
					txt.text = "连接关闭";
					break;
			}
			
		}
		public function returnConnect(str:String):void{
			history.text = str;
		}
		
		private function closeBtnHandler(event:MouseEvent):void{
			coBtn.enabled = true;
			closeBtn.enabled = false;
			sendBtn.enabled = false;
			testTxt.type = TextFieldType.INPUT;
			nc.close();
			cleanAll();
		}
		private function cleanAll():void{
			userName.text = "";
			history.text = "";
			input.text = "";
			var tmpDP:DataProvider = new DataProvider();
			toName.dataProvider = tmpDP;
		}
		// //connect
		
		//user list
		private function setListSO() {
			listSO = SharedObject.getRemote("listSO", nc.uri, false);
			listSO.connect(nc);
			listSO.addEventListener(SyncEvent.SYNC, listSOSyncHandler);
		}
		private function listSOSyncHandler(event:SyncEvent) {//对服务器端listSO对象监听，该对象更新后执行。
			showUserList();
			//toName.addEventListener(MouseEvent.DOUBLE_CLICK, _updateVideoShow);
		}
		
		private function showUserList() {
			userArr = new Array();
			for (var tmp in listSO.data) {
				userArr.push(listSO.data[tmp]);
			}
			
			//向list中添加数据
			var tmpDP:DataProvider = new DataProvider();
			for (var i = 0; i < userArr.length; i++ ) {
				tmpDP.addItem( { label:userArr[i] } );
			}
			tmpDP.sortOn("label");//名称排序
			tmpDP.addItemAt( { label:everyBody }, 0);
			toName.dataProvider = tmpDP;
		}
		
		// //user list
		
		//消息共享对象
		private function setMsgSO() {
			msgSO = SharedObject.getRemote("msgSO", nc.uri, false);
			msgSO.addEventListener(SyncEvent.SYNC, msgSOSyncHandler);
			msgSO.connect(nc);
		}
		private function msgSOSyncHandler(event:SyncEvent) {//对服务器端msgSO对象监听，该对象更新后执行。
			//更新聊天内容
			for (var i in msgSO.data) {
				history.htmlText += msgSO.data[i];
			}
		}
		// //消息共享对象
		
		//send message
		private function sendBtnHandler(event:MouseEvent):void{
			var tempTxt:String
			tempTxt="<font color='#0000ff'>"+userName.text+"</font>"+" 对 "+"<font color='#0000ff'>"+toName.text+"</font>" + " 说 " + "(" + getTime() + ")" + ":" +"\t" + input.text + "\n";
			if(input.text==""){
				alert.text = "先填写消息！";
			}else{
				if(toName.text == everyBody){
					nc.call("broadcastUserMsg", null, tempTxt);
					input.text = "";
				}else if(toName.text == userName.text){
					alert.text = "请选择其他人聊天!";
				}else{
					alert.text = "";
					nc.call("msgFromPrivate", null,tempTxt, userName.text, toName.text);
					input.text = "";
				}
			}
		}
		private function getTime():String{
			var time:String = "<font color='#666666'>" + now.getHours() + ":" + (now.getMinutes() < 10?"0" + now.getMinutes():now.getMinutes()) + ":" + (now.getSeconds() < 10?"0" + now.getSeconds():now.getSeconds()) + "</font>";
			return time;
		}
		public function showMsgByPrivate(str:String) {
			history.htmlText += str;
			scrollToEnd();
		}
		private function scrollToEnd() {
			history.verticalScrollPosition = history.maxVerticalScrollPosition;
		}
		
		// //send message
		

		/*
		private function login_Result(re) {
			trace("broadcast success:"+re);
		}
		private function login_Fault(fe) {
			trace("broadcast failed:"+fe);
		}
		*/
	}
}