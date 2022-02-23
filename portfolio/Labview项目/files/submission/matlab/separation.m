function [TT,FF] = separation(Tor, For)
%SEPARATION     Input the torque and force, this function will separate the signal 
%               and then output the separated matrices that each column
%               represent of each drilling precedure interval.
    %% Start to segement Force
    [TF,S1,S2] = ischange(For,'linear','Threshold',200);    
    
    rlt = find(S1<-102);    %The threshold found for this signal after using the ischange() function is -102
    border(1,1) = rlt(1,1); %For the initial border
    cnt = 1;
    for i = 1: length(rlt) - 1 
        if(abs(rlt(i+1,1)) - abs(border(cnt,1))>20000)  %Avoid the interaction of signal at same 
                                                        %period.
            cnt = cnt+1;
            border(cnt,1) = rlt(i+1,1); %Find the border
        else
            border(cnt,1) = rlt(i+1,1); %Make sure in a period of time step,
                                        %the border will always locate at the end
        end
    end
    
    %cell struct to contain the result
    FF = cell(9,1);
    for i = 1: 9
        bor = border(i,1);
        F(:,i) = For(bor-35000:bor-1000,1);  %For each drilling precedure, 
                                             %before the end side, there
                                             %are 34001 time interval being
                                             %chosen
        %find the start border, and since the start and end border, the signal
        %can be separated.
        [TF,S1,S2] = ischange(F(:,i),'linear','Threshold',10);
        %plot(S1);
        rlt_s = find(S1>12);
        border_s = bor - 35000 + rlt_s(1,1);
        FF{i,1} = For(border_s+2000:bor-1000,1);    %Avoid noise as remove the 2000 from start and 
                                                    %1000 time interval
                                                    %before end
%         figure;
%         plot(FF{i,1}(:,1));
    end

    
    %% Start to segement torque
    [TF,S1,S2] = ischange(Tor,'linear','Threshold',0.5);
    
    rlt = find(S1<-1.09);
    border(1,1) = rlt(1,1);
    cnt = 1;
    for i = 1: length(rlt) - 1 
        if(abs(rlt(i+1,1)) - abs(border(cnt,1))>20000)
            cnt = cnt+1;
            border(cnt,1) = rlt(i+1,1);
        else
            border(cnt,1) = rlt(i+1,1);
        end
    end

    %cell struct to contain the result
    TT = cell(9,1);
    for i = 1: 9
        bor = border(i,1);
        T(:,i) = Tor(bor-32000:bor-700,1);   %For each drilling precedure, 
                                             %before the end side, there
                                             %are 31301 time interval being
                                             %chosen
        [TF,S1,S2] = ischange(T(:,i),'linear','Threshold',0.01);
        %figure;
        %plot(S1);
        rlt_s = find(S1<-0.1);
        border_s = bor - 32000 + rlt_s(1,1);
        TT{i,1} = Tor(border_s+2000:bor-1000,1);    %Avoid noise as remove the 2000 from start and 
                                                    %1000 time interval
                                                    %before end
        %figure;
        %plot(TT{i,1}(:,1));
    end
end









