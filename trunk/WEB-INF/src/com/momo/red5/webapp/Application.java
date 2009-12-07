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
		// ����ʱ������ID��������Ϣ�γɶ�Ӧ��ϵ�����������б�
		String link_id = conn.getClient().getId();
		onLineClient.put(username, conn);
		// Ϊ�û��б�������������
		// �����û��б������
		listSO = getSharedObject(appScope, "listSO", false);
		// �����û��������ݹ������
		msgSO = getSharedObject(appScope, "msgSO", false);
		listSO.setAttribute(link_id, username);
		return true;
		
	}

	// �㲥��Ϣ
	public String broadcastUserMsg(String msg) {
		// ����
		// ˢ�¹����������
		msgSO.setAttribute("msg", msg);
		return msg;
	}

	// ˽����Ϣ
	public void msgFromPrivate(String msg, String from, String to) {
		IServiceCapableConnection fc = (IServiceCapableConnection) onLineClient.get(from);
		IServiceCapableConnection tc = (IServiceCapableConnection) onLineClient.get(to);
		fc.invoke("showMsgByPrivate", new Object[] { msg });
		tc.invoke("showMsgByPrivate", new Object[] { msg });
	}

	// �û��Ͽ����ӵ�ʱ�򴥷�
	public void appDisconnect(IConnection conn) {
		String dis_link_id = conn.getClient().getId();
		String user = (String) listSO.getAttribute(dis_link_id);
		// ����IDɾ����Ӧ���߼�¼
		onLineClient.remove(user);
		// ɾ���û��б������Ķ�Ӧ����
		listSO.removeAttribute(dis_link_id);
	}
	
	
	
	
	
}