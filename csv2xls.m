clc,clear
%% ��������csvΪһ��xls������DF/F0,mean,SEM,peak DF/f0
[file,path] = uigetfile('*.csv');%csv�ļ�·��
% path=cd('F:\2P-brain slices-439\20200920 hsyn-oxt1.0 VTA\slice2\acsf'); %csv�ļ�·��
list=dir([path,'\*.csv']); %��ȡ·��������csv�ļ���Ϊһ��list
P=[];M=[];S=[];O=[];Q=[];U=[];AUC=[];peak=[];AUCms=[];
num=200;%֡��
trial=3;%repeat����
t=10; %�̼���ʼʱ��
%˫���Ӳ���Ƶ��
%122:128*96 2us/p 0.1482s/frame;256*192 2us/p 0.358259s/frame;256*256 0.431493s/frame
%439:256*256 2x 1.2us/p 0.2573s/frame, 8x 0.1963s/frame, 1x 0.3259s/frame;512*512,1.0861s/frame 
%401:256x192 0.3111s/frame
T=0.3583;
time=(T*[1:num]-t)'; %��t��Ϊ���
for i = 1:length(list)
    space=strfind(list(i).name,' '); %�����ļ����еĿո�λ��
%     space(3)=strfind(list(i).name,'-'); %����439�ļ����е�-λ��
    volt{i}=list(i).name(1:space(1)-1); %��ȡ��ѹ
    freq{i}=list(i).name(space(1)+1:space(2)-1); %��ȡƵ��
    dura{i}=list(i).name(space(2)+1:space(3)-2); %��ȡʱ��/pulse number
    if i==1
        trial_num=1; %��1��trial
        trial_group{1}=dura{i}; %trial���
        trial_count(trial_num)=1; %trial������
    else
        if strcmp(dura{i},dura{i-1})
            trial_count(trial_num)=trial_count(trial_num)+1; %trial������
        else
            trial_num=1+trial_num; %�ڼ���trial
            trial_group{trial_num}=dura{i}; %trial���
            trial_count(trial_num)=1; %trial������
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
    F=csvread(input,1,1,[1,1,num,1]); %��ȡcsv�ļ�[2,num+1]�У�[2,3]��
    AUC(i)=trapz(ceil(t/T):1:num,F(ceil(t/T):num));%����0-end���������
    f=movmean(F,5); %��������5�����ݵ�ľ�ֵ
    peak(i)=min(f(abs(f)==max(abs(f(floor(t/T):floor((t+10)/T))))));%����0-25s���ֵ
    figure,plot(F); %��ÿ��trial��ͼ
    hold on
    plot(f);
    P=[P,F]; %��������trial��DF/F0
end
output=[path,'\','result.xlsx'];

for i = 1:trial_num
    M=mean(P(:,listNo_post{i}),2); %��Mean
    S=std(P(:,listNo_post{i}),0,2)/sqrt(trial_count(i)-1); %��SEM
    O=[O,M,S]; %��ֵ+SEM
    AUCm(i)=mean(AUC(:,listNo_post{i}),2); %��Mean
    R=movmean(M(floor(t/T):floor((t+10)/T)),5);%�����ƶ���ֵ��peak��window=5,�޶���Χ�̼���ʼ���̼���ʼ��20��
    U(i)=R(abs(R)==max(abs(R))); %ȡ����ֵ���ĵ��Ӧ��df/f0��Ϊpeak
    Q=[Q,movmean(M,5)];
end
sheet1='single'; %����trial��trace
xlswrite(output,[time,P],sheet1);
sheet2='mean+sem'; %mean+sem
xlswrite(output,[time,O],sheet2);
sheet3='peak'; %peak
xlswrite(output,U,sheet3);
sheet4='movmean'; %�ƶ���ֵ
xlswrite(output,[time,Q],sheet4);
sheet5='single-auc'; %area under curve
xlswrite(output,AUC,sheet5);
sheet6='single-peak'; 
xlswrite(output,peak,sheet6);
sheet7='auc-mean'; %area under curve
xlswrite(output,AUCm,sheet7);