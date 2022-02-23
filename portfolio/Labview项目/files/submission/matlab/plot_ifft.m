function [ifftF_T]=plot_ifft(Fs, totalname,CT_F,xname,yname,tname)
    num = 1;
    ifftF_T = cell(9,1);
    num = 1;
    for row = 1: 3
        figure;
        sgtitle(totalname);
        for col = 1: 3
            Tor1 = CT_F{num,1}(:,1);
            Tor1_after2 = Tor1 - mean(Tor1);
            F = fft(Tor1_after2);
            LTT_ = length(Tor1_after2);
            subplot(3,1,col);
            Freq = ((0:1/LTT_:1-1/LTT_)*Fs).';
            F(Freq>=90 & Freq<=Fs-90) = 0; %Cut off frequency
            ifft_Torque = ifft((F));% ifft
            plot(real(ifft_Torque)+mean(Tor1));
            ifftF_T{num,1} = real(ifft_Torque)+mean(Tor1);
            title([tname,num2str(num)]);
            xlabel([xname,' ']),ylabel([yname,' ']);
            num = num + 1;
        end
    end
end