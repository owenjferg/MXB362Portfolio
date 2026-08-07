clear all

load USA_County_struct.mat
load USA_State_struct.mat

[D,T] = xlsread('Geocoded_MethLabs.xlsx');
Loc = [D(:,11) D(:,10)];

figure(1); clf, hold on; box on;

for s = 1:length(S)
    XX = S(s).X;
    YY = S(s).Y;

    plot(XX,YY,'color',0.8.*ones(1,3));
end

ml = plot(Loc(:,1),Loc(:,2),'r.','markersize',4);

FS = 16;
title('Locations of methamphetamine labortories','fontsize',FS);
text(-124,24.3,'Source: DEA National Clandestine Laboratory Register','fontsize',FS)

set(gca,'xtick',[],'ytick',[])
xlim([-126 -66]);
ylim([23.3 50]);


figure(2), clf, hold on; box on;

CL = hot(3200);
CL = CL(end:-1:1,:);

for s = 1:length(S_states)
    XX = S_states(s).X;
    YY = S_states(s).Y;

    LabsInThisStates(s) = sum(inpolygon(Loc(:,1),Loc(:,2),XX,YY));

    ThisColor = ceil(LabsInThisStates(s))+1;

    P = nanpatch_MXB362 (XX,YY,CL(ThisColor,:));
end

FS = 16;
set(gca,'xtick',[],'ytick',[]);
xlim([-126, -66]); ylim([23.5 50])
colormap(CL); C = colorbar;
title('Number of methamphetamine labs in each state','fontsize',FS);
set(C,'Ticks',linspace(0,1,9),'ticklabels',linspace(0,3200,9),'fontsize',FS-2);

