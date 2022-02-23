function [] = plot_average(totalname,timeCT,xname,CT_F,yname,tname)
    num = 1;
    for row = 1: 3
        figure;
        sgtitle(totalname,'FontSize',17);
        for col = 1: 3
            meanTor = mean(CT_F{num,1}(:,1));
            mTor = CT_F{num,1}(:,1) - meanTor;
            eval(['aTor',num2str(num),'= mTor;']);
            subplot(3,1,col);
            plot(timeCT{num,1},mTor, 'r', 'linewidth', 1); % plot torque data with the moving average removed
            title([tname,' ',num2str(num)],'FontSize',17);
            xlabel([xname,' '],'FontSize',17),ylabel([yname,' '],'FontSize',17);
            grid on
            num = num + 1;
            x=gca; % Managing Fontsizes on axes
            x.FontSize=15;
            x.LabelFontSizeMultiplier=1.4;
        end
    end
end