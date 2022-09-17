clc,clear
%% 整合所有csv为一个xls，计算DF/F0,mean,SEM,peak DF/f0
[file,path] = uigetfile('*.csv');%csv文件路径
% path=cd('F:\2P-brain slices-439\20200920 hsyn-oxt1.0 VTA\slice2\acsf'); %csv文件路径
list=dir([path,'\*.csv']); %提取路径下所有csv文件名为一个list
P=[];M=[];S=[];O=[];Q=[];U=[];AUC=[];peak=[];AUCms=[];
num=200;%帧数
trial=3;%repeat次数
t=10; %刺激开始时间
%双光子采样频率
%122:128*96 2us/p 0.1482s/frame;256*192 2us/p 0.358259s/frame;256*256 0.431493s/frame
%439:256*256 2x 1.2us/p 0.2573s/frame, 8x 0.1963s/frame, 1x 0.3259s/frame;512*512,1.0861s/frame 
%401:256x192 0.3111s/frame
T=0.3583;
time=(T*[1:num]-t)'; %第t秒为零点
for i = 1:length(list)
    space=strfind(list(i).name,' '); %查找文件名中的空格位置
%     space(3)=strfind(list(i).name,'-'); %查找439文件名中的-位置
    volt{i}=list(i).name(1:space(1)-1); %读取电压
    freq{i}=list(i).name(space(1)+1:space(2)-1); %读取频率
    dura{i}=list(i).name(space(2)+1:space(3)-2); %读取时间/pulse number
    if i==1
        trial_num=1; %第1个trial
        trial_group{1}=dura{i}; %trial组别
        trial_count(trial_num)=1; %trial组别计数
    else
        if strcmp(dura{i},dura{i-1})
            trial_count(trial_num)=trial_count(trial_num)+1; %trial组别计数
        else
            trial_num=1+trial_num; %第几个trial
            trial_group{trial_num}=dura{i}; %trial组别
            trial_count(trial_num)=1; %trial组别计数
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
    F=csvread(input,1,1,[1,1,num,1]); %读取csv文件[2,num+1]行，[2,3]列
    AUC(i)=trapz(ceil(t/T):1:num,F(ceil(t/T):num));%计算0-end曲线下面积
    f=movmean(F,5); %计算连续5个数据点的均值
    peak(i)=min(f(abs(f)==max(abs(f(floor(t/T):floor((t+10)/T))))));%计算0-25s最大值
    figure,plot(F); %画每个trial的图
    hold on
    plot(f);
    P=[P,F]; %保存所有trial的DF/F0
end
output=[path,'\','result.xlsx'];

for i = 1:trial_num
    M=mean(P(:,listNo_post{i}),2); %求Mean
    S=std(P(:,listNo_post{i}),0,2)/sqrt(trial_count(i)-1); %求SEM
    O=[O,M,S]; %均值+SEM
    AUCm(i)=mean(AUC(:,listNo_post{i}),2); %求Mean
    R=movmean(M(floor(t/T):floor((t+10)/T)),5);%根据移动均值算peak，window=5,限定范围刺激开始到刺激开始后20秒
    U(i)=R(abs(R)==max(abs(R))); %取绝对值最大的点对应的df/f0作为peak
    Q=[Q,movmean(M,5)];
end
sheet1='single'; %单个trial的trace
xlswrite(output,[time,P],sheet1);
sheet2='mean+sem'; %mean+sem
xlswrite(output,[time,O],sheet2);
sheet3='peak'; %peak
xlswrite(output,U,sheet3);
sheet4='movmean'; %移动均值
xlswrite(output,[time,Q],sheet4);
sheet5='single-auc'; %area under curve
xlswrite(output,AUC,sheet5);
sheet6='single-peak'; 
xlswrite(output,peak,sheet6);
sheet7='auc-mean'; %area under curve
xlswrite(output,AUCm,sheet7);