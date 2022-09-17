clc,clear
%% integrate single trial csv files to xls，calculate DF/F0,mean,SEM,peak DF/f0
[file,path] = uigetfile('*.csv');
% path=cd('F:\2P-brain slices-439\20200920 hsyn-oxt1.0 VTA\slice2\acsf');
list=dir([path,'\*.csv']); 
P=[];M=[];S=[];O=[];Q=[];U=[];AUC=[];peak=[];AUCms=[];
num=200;
trial=3;
t=10; 
T=0.3583;
time=(T*[1:num]-t)';
for i = 1:length(list)
    space=strfind(list(i).name,' ');
%     space(3)=strfind(list(i).name,'-');
    volt{i}=list(i).name(1:space(1)-1);
    freq{i}=list(i).name(space(1)+1:space(2)-1);
    dura{i}=list(i).name(space(2)+1:space(3)-2);
    if i==1
        trial_num=1;
        trial_group{1}=dura{i};
        trial_count(trial_num)=1;
    else
        if strcmp(dura{i},dura{i-1})
            trial_count(trial_num)=trial_count(trial_num)+1; 
        else
            trial_num=1+trial_num; 
            trial_group{trial_num}=dura{i}; 
            trial_count(trial_num)=1; 
        end
    end
end
for i=1:trial_num
    trial_Group(i)=str2num(trial_group{i});
end
trial_Group=sort(trial_Group);
for i=1:trial_num
    trial_group{i}=num2str(trial_Group(i));
end
for i=1:trial_num
    listNo{i}=find(ismember(dura,trial_group{i}));
    listNo_post{i}=sum(trial_count(1:i-1))+[1:trial_count(i)];
end
listNo_mat=cell2mat(listNo);
 for i = 1:length(list)
    input=[path,'\',list(listNo_mat(i)).name];
    F=csvread(input,1,1,[1,1,num,1]); 
    AUC(i)=trapz(ceil(t/T):1:num,F(ceil(t/T):num));
    f=movmean(F,5);
    peak(i)=min(f(abs(f)==max(abs(f(floor(t/T):floor((t+10)/T))))));
    figure,plot(F);
    hold on
    plot(f);
    P=[P,F];
end
output=[path,'\','result.xlsx'];

for i = 1:trial_num
    M=mean(P(:,listNo_post{i}),2);
    S=std(P(:,listNo_post{i}),0,2)/sqrt(trial_count(i)-1);
    O=[O,M,S]; 
    AUCm(i)=mean(AUC(:,listNo_post{i}),2); 
    R=movmean(M(floor(t/T):floor((t+10)/T)),5);
    U(i)=R(abs(R)==max(abs(R))); 
    Q=[Q,movmean(M,5)];
end
sheet1='single'; 
xlswrite(output,[time,P],sheet1);
sheet2='mean+sem';
xlswrite(output,[time,O],sheet2);
sheet3='peak';
xlswrite(output,U,sheet3);
sheet4='movmean';
xlswrite(output,[time,Q],sheet4);
sheet5='single-auc'; 
xlswrite(output,AUC,sheet5);
sheet6='single-peak'; 
xlswrite(output,peak,sheet6);
sheet7='auc-mean';
xlswrite(output,AUCm,sheet7);
