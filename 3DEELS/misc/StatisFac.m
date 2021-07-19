function sta=StatisFac(ene)
sta=((1+1./(exp(ene*0.0396)-1))./ene)+(-(1./(exp(-ene*0.0396)-1))./ene);sta(ene<=0)=inf;
end