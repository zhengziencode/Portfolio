function [] = plot_fft(Frequency,totalname,CT_F,xname,yname,tname)
%num = 1;
for i = 1:9
    figure;
    %sgtitle(totalname, 'FontSize',17);
    Tor1 = CT_F{i,1}(:,1);% set paremeter
    Tor1_after2 = Tor1 - mean(Tor1);% detrend signal
    F = fft(Tor1_after2); % fft to detrend data
    LTT = length(Tor1_after2); % measure length of detrend data 
    P1 = abs(F/LTT); % 
    P2 = P1(1:LTT/2+1);
    P2(2:end-1) = 2*P2(2:end-1);
    f = Frequency*(0:(LTT/2))/LTT;
    %subplot(2,2,num);
    plot(f,P2,'LineWidth',1.65) ;
    title([totalname,' ',tname,' ',num2str(i)],'FontSize',17);
    xlabel([xname],'FontSize',17),ylabel([yname],'FontSize',17);
    x=gca; % Managing Fontsizes on axes
    x.FontSize=15;
    x.LabelFontSizeMultiplier=1.4;
%     eval(['title(''Single-Sided Amplitude Spectrum of T',num2str(i),''');']);
%     xlabel('f (Hz)');
%     ylabel('|P2(f)|') ;
    %num = num + 1;
end