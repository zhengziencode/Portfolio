function R=SR(FFb,fp2)
%SR     This function is used for calculating the residuals 
    SSres=0;
    SST=0;
    for i=1:length(FFb)
        SST1=(FFb(i)-mean(FFb)).^2;
        SST=SST1+SST;
        SSres1=(FFb(i)-fp2(i)).^2;
        SSres=SSres1+SSres;
    end
    R=1-SSres/SST;

end