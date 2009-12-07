package com.momo.red5.webapp;

import java.util.*;
import org.red5.server.adapter.ApplicationAdapter;
import org.red5.server.api.IConnection;
import org.red5.server.api.IScope;
import org.red5.server.api.service.IServiceCapableConnection;
import org.red5.server.api.so.ISharedObject;

public class Application extends ApplicationAdapter {
	
	private String username;	
	
	private IScope appScope;

	private ISharedObject listSO;

	private ISharedObject msgSO;

	private Map<String, IConnection> onLineClient = new HashMap<String, IConnection>();
	
	public boolean appStart(IScope app) {
		if (!super.appStart(app)) {
			return false;
		}
		appScope = app;
		return true;
	}
	
	public boolean appConnect(IConnection conn,Object[] params) {
		/*
		username=(String)params[0];
		IServiceCapableConnection sc=(IServiceCapableConnection)conn;
		sc.invoke("returnConnect",new Object[]{username});
		return true;
		*/
		
		username = (String) params[0];
		// 登入时将连接ID和连接信息形成对应关系并存入在线列表
		String link_id = conn.getClient().getId();
		onLineClient.put(username, conn);
		// 为用户列表共享对象添加属性
		// 创建用户列表共享对象
		listSO = getSharedObject(appScope, "listSO", false);
		// 创建用户聊天内容共享对象
		msgSO = getSharedObject(appScope, "msgSO", false);
		listSO.setAttribute(link_id, username);
		return true;
		
	}

	// 广播消息
	public String broadcastUserMsg(String msg) {
		// 公聊
		// 刷新共享对象属性
		msgSO.setAttribute("msg", msg);
		return msg;
	}

	// 私聊信息
	public void msgFromPrivate(String msg, String from, String to) {
		IServiceCapableConnection fc = (IServiceCapableConnection) onLineClient.get(from);
		IServiceCapableConnection tc = (IServiceCapableConnection) onLineClient.get(to);
		fc.invoke("showMsgByPrivate", new Object[] { msg });
		tc.invoke("showMsgByPrivate", new Object[] { msg });
	}

	// 用户断开连接的时候触发
	public void appDisconnect(IConnection conn) {
		String dis_link_id = conn.getClient().getId();
		String user = (String) listSO.getAttribute(dis_link_id);
		// 根据ID删除对应在线纪录
		onLineClient.remove(user);
		// 删除用户列表共享对象的对应属性
		listSO.removeAttribute(dis_link_id);
	}
	
	
	
	
	
}