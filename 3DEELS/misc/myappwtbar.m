function []=myappwtbar(x,msg)
if nargin<2
    msg='Please wait';
end
persistent f
if isempty(f)
    f=findall(0,'Type', 'figure','Tag', '3DEELSTOOLBOX');
end
if ~isempty(f)
    persistent s
    if isempty(s)
        s=clock;
    end
    tpass = etime(clock,s);
    if tpass>5||x>0.1
        tremain=tpass/x*(1-x);
    else
        tremain=nan;
    end
    %     if isempty(dlg)
    %         dlg= uiprogressdlg(f,'Title',msg,...
    %             'Message',['remaining time = ',num2str(tremain,'%4.1f'),' sec' ],'Indeterminate','off');
    %     else
    f.UserData.Value=x;
    f.UserData.Message=['remaining time = ',num2str(tremain,'%4.1f'),' sec' ];
    f.UserData.Title=msg;
    f.UserData.Indeterminate='off';
    %     end
    if x>0.9999
        %         close(dlg)
        clear('f')
        %         clear('dlg')
        clear('s')
        f.UserData.Indeterminate='on';
        f.UserData.Title='Please wait';
    end
else
    mywaitbar(x, msg);
end
end
