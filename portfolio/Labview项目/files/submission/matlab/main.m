clc;
clear;
close all;
%% Input data set parameter
M = importdata('abc.csv'); % read data from csv
M = M.data; % collect data from structure data
Tor = (M(:,1) - 2048) * 20 / 4096 / 100 * 200; % input Torque datasets and convert data from count into torque
For = (M(:,2) -20480) * 20 / 4096  * 500; % input Thrust datasets and convert data from count into thrust force

Tt = M(:,3);  %input Time
Time = (floor(1:length(Tt))/10); % use a created time to replace the original one

figure;
subplot(3,1,1);% show raw Force data
plot(Time,For);
ylim([-1000,4000]);
title('ThrustForce(Rawdata)','FontSize',17);
xlabel('Time / (ms)','FontSize',17),ylabel('Thrust Force / (N)','FontSize',17);
grid on
subplot(3,1,2);% show raw Torque data
plot(Time,Tor);
ylim([-5,15]);
xlabel('Time / (ms)','FontSize',17),ylabel('Torque / (Nm)','FontSize',17)
title('Torque(Rawdata)','FontSize',17);
grid on
subplot(3,1,3);% show raw Time data
plot(Tt);
title('Time(Rawdata)','FontSize',17);
ylabel('Time / (ms)','FontSize',17);
xlabel('Number of Samples','FontSize',17) 
grid on
%% segment raw data
[TT,FF] = separation(Tor, For);% seperate raw data
LTT = zeros(9,1);
LFF = zeros(9,1);
timeTT = cell(9,1);
timeFF = cell(9,1);
for i = 1:9
    LTT(i,1) = length(TT{i,1}(:,1)); %data length of Torque
    LFF(i,1) = length(FF{i,1}(:,1)); %data length of Force
    timeTT{i,1} = 0:1/10000:(LTT(i,1)-1)/10000; % calculate t segment of each Torque data
    timeFF{i,1} = 0:1/10000:(LFF(i,1)-1)/10000; % calculate t segment of each Force data
end
Feeding_r = [267,380,496];          %List of feeding rate
Spindle_spd = [1700, 2450, 3190];   %List of spindle speed
%% Segment RawForce
index = 1;
for row = 1:3
    figure;
    eval(['sgtitle(''Segment Force, Row: ',num2str(row),''')']);
    for col = 1:3
        subplot(1,3,col);
        plot(FF{index,1}(:,1));
        title({['Feeding speed(mm/min):',num2str(Feeding_r(col))];['Spindle speed(rpm):',num2str(Spindle_spd(row))]});
        xlabel('Time / (ms)'),ylabel('Thrust Force / (N)');
        if(index == 4)
            subplot(1,3,1)
            plot(FF{4,1}(:,1))
            ylim([600,1300]);
            title({['Feeding speed(mm/min):267'];['Spindle speed(rpm):2450']});
            xlabel('Time / (ms)'),ylabel('Thrust force / (N)');
        end
        index = index+1;
    end
end
%% Segment RawTorque
index = 1;
for row = 1:3
    figure;
    eval(['sgtitle(''Segment Torque, Row: ',num2str(row),''')']);
    for col = 1:3
        subplot(1,3,col);
        plot(TT{index,1}(:,1));
        title({['Feeding speed(mm/min):',num2str(Feeding_r(col))];['Spindle speed(rpm):',num2str(Spindle_spd(row))]});
        xlabel('Time / (ms)'),ylabel('Torque / (N·m)');
        if(index == 7)
            subplot(1,3,1)
            plot(TT{7,1}(:,1))
            ylim([0,6]);
            title({['Feeding speed(mm/min):267'];['Spindle speed(rpm):3190']});
            xlabel('Time / (ms)'),ylabel('Torque / (Nm)');
        end
        index = index+1;
    end
end

%% chauvenet remove spike
cTor = chauvenet(Tor); % use chauvenet function to remove spike
cFor = chauvenet(For);
figure; %show figure which has been removed spike
subplot(2,1,2);
plot(cFor);
title('Thrust Force','FontSize',18),xlabel('Number of samples','FontSize',18),ylabel('Thrust Force / (N)','FontSize',18);
x=gca; % Managing Fontsizes on axes
        x.FontSize=15;
        x.LabelFontSizeMultiplier=1.4;
grid on
subplot(2,1,1);
plot(cTor);
title('Torque','FontSize',18),xlabel('Number of samples','FontSize',18),ylabel('Torque / (Nm)','FontSize',18);
x=gca; % Managing Fontsizes on axes
        x.FontSize=15;
        x.LabelFontSizeMultiplier=1.4;
grid on

%% Segment after removing spike
[CT,CF] = separation(cTor, cFor); % seperate data without spike
LCT = zeros(9,1);
LCF = zeros(9,1);
timeCT = cell(9,1);
timeCF = cell(9,1);
for i = 1:9
    LCT(i,1) = length(CT{i,1}(:,1)); %data length of Torque without spike
    LCF(i,1) = length(CF{i,1}(:,1)); %data length of Force without spike
    timeCT{i,1} = 0:1/10000:(LCT(i,1)-1)/10000; % calculate t segment of each Torque data
    timeCF{i,1} = 0:1/10000:(LCF(i,1)-1)/10000;% calculate t segment of each Force data
end
%% average
plot_average('Remove Average Torque',timeCT,'Time / (s)',CT,'Torque / (Nm)','Torque');
plot_average('Remove Average Force',timeCF,'Time / (s)',CF,'Force / (N)','Force');
%% FFT
% sampling frequency
% Torque FFT
Frequency = 10000;
plot_fft(Frequency,'FFT',CT,'f (Hz)','|P2(f)|','Single-Sided Amplitude Spectrum of T')
%% Force FFT
Frequency = 10000;
plot_fft(Frequency,'FFT',CF,'f (Hz)','|P2(f)|','Single-Sided Amplitude Spectrum of F')
%% Filtered Torque data
ifftTorque = plot_ifft(10000,'Filtered Torque data',CT,'Times(ms)','Torque / (Nm)','Torque');
%% Filtered Force data
ifftForce = plot_ifft(10000, 'Filtered Force data',CF,'Times(ms)','Force / (N)','Force');

%% curve fitting
% Setting variables
ss =[1700,2450,3190]; %Spindle speed
%Mean of Filtered Torque data
mean_filtered_torque =zeros(1,9);% initialize torque data
for i = 1:9
    mean_filtered_torque(1,i) = mean(ifftTorque{i,1}(1,:));
end
% Mean of Filtered Force data
mean_filtered_force =zeros(1,9);% initialize force data
for i = 1:9
    mean_filtered_force(1,i) = mean(ifftForce{i,1}(1,:));
end
T = (reshape(mean_filtered_torque,[3,3]))';
F = (reshape(mean_filtered_force,[3,3]))';
poly = zeros(2,3);

figure;
for i = 1:3
    poly(:,i)=polyfit(ss,T(:,i),1);
    fp=polyval(poly(:,i),ss);
    R2(i)=SR(T(:,i),fp);
    str(i) = ['y='+string(poly(1,i))+'x+'+string(poly(2,i))];
    if i == 1
        plot(ss,fp,'r',ss,T(:,i),'o','LineWidth',1.5)
        hold on 
    end
    if i == 2
        plot(ss,fp,'y',ss,T(:,i),'*','LineWidth',1.5)
        hold on 
    end
    if i == 3
        plot(ss,fp,'b',ss,T(:,i),'+','LineWidth',1.5)
        hold on 
    end
end
title('Torque against spindle speed')
xlabel('Spindle speed(rpm)');
ylabel('Torque(N.m)')
legend('data1','Feed267mm/min','data2','Feed380mm/min','data3','Feed496mm/min','Location','best');

figure
name={'Feed','Thrust','R^2'};
PR=uitable('ColumnName',name,'Position',[100,100,380,200],'ColumnWidth',{150,150,'auto','auto'});
table_data = {'267mm/min',char(str(1)),R2(1);'380mm/min',char(str(2)),R2(2);'496mm/min',char(str(3)),R2(3)};
set(PR,'data',table_data);

figure
for i = 1:3
    poly(:,i)=polyfit(ss,F(:,i),1);
    fp=polyval(poly(:,i),ss);
    R2(i+3)=SR(F(:,i),fp);
    str(i+3) = ['y='+string(poly(1,i))+'x+'+string(poly(2,i))];
    if i == 1
        plot(ss,fp,'r',ss,F(:,i),'o','LineWidth',1.5)
        hold on 
    end
    if i == 2
        plot(ss,fp,'y',ss,F(:,i),'*','LineWidth',1.5)
        hold on 
    end
    if i == 3
        plot(ss,fp,'b',ss,F(:,i),'+','LineWidth',1.5)
        hold on 
    end
end
title('Thrust Force (N) against spindle speed')
xlabel('Spindle speed(rpm)');
ylabel('Thrust Force (N)');
legend('data1','Feed267mm/min','data2','Feed380mm/min','data3','Feed496mm/min','Location','best');

figure
name={'Feed','Thrust Force','R^2'};
PR=uitable('ColumnName',name,'Position',[100,100,380,200],'ColumnWidth',{150,150,'auto','auto'});
table_data = {'267mm/min',char(str(4)),R2(4);'380mm/min',char(str(5)),R2(5);'496mm/min',char(str(6)),R2(6)};
set(PR,'data',table_data);

fr=[267,380,496];%Feeding rate
figure 
for i = 1:3
    poly(:,i)=polyfit(fr,T(i,:),1);
    fp=polyval(poly(:,i),fr);
    R2(i+6)=SR(T(i,:),fp);
    str(i+6) = ['y='+string(poly(1,i))+'x+'+string(poly(2,i))];
    if i == 1
        plot(fr,fp,'r',fr,T(i,:),'o','LineWidth',1.5)
        hold on 
    end
    if i == 2
        plot(fr,fp,'y',fr,T(i,:),'*','LineWidth',1.5)
        hold on 
    end
    if i == 3
        plot(fr,fp,'b',fr,T(i,:),'+','LineWidth',1.5)
        hold on 
    end
end
title('Torque against feeding rate')
xlabel('Feeding speed (mm/min)')
ylabel('Torque(N*m)')
legend('data1','Feeding rate 267 mm/min','data2','Feeding rate 380 mm/min','data3','Feeding rate 496 mm/min','Location','best');

figure
name={'Feed','Thrust','R^2'};
PR=uitable('ColumnName',name,'Position',[100,100,380,200],'ColumnWidth',{150,150,'auto','auto'});
table_data = {'267mm/min',char(str(7)),R2(7);'380mm/min',char(str(8)),R2(8);'496mm/min',char(str(9)),R2(9)};
set(PR,'data',table_data);

figure 
for i = 1:3
    poly(:,i)=polyfit(fr,F(i,:),1);
    fp=polyval(poly(:,i),fr);
    R2(i+9)=SR(F(i,:),fp);
    str(i+9) = ['y='+string(poly(1,i))+'x+'+string(poly(2,i))];
    if i == 1
        plot(fr,fp,'r',fr,F(i,:),'o','LineWidth',1.5)
        hold on 
    end
    if i == 2
        plot(fr,fp,'y',fr,F(i,:),'*','LineWidth',1.5)
        hold on 
    end
    if i == 3
        plot(fr,fp,'b',fr,F(i,:),'+','LineWidth',1.5)
        hold on 
    end
end

title('Thrust force against feeding rate')
xlabel('Feeding speed (mm/min)')
ylabel('Thrust force (N)')
legend('data1','Feeding rate 267 mm/min','data2','Feeding rate 380 mm/min','data3','Feeding rate 496 mm/min','Location','best');

figure
name={'Feed','Torque','R^2'};
PR=uitable('ColumnName',name,'Position',[100,100,380,200],'ColumnWidth',{150,150,'auto','auto'});
table_data = {'267mm/min',char(str(10)),R2(10);'380mm/min',char(str(11)),R2(11);'496mm/min',char(str(12)),R2(12)};
set(PR,'data',table_data);




