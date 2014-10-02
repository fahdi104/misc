%Converting SEG/EAGE 3D Overthrust Model from Binary to SGY
%It's a long way, and a stupid process
%From Binary, read in RSF to SGY
%From SGY to SU
%From SU to ASCII
%Modify, back to SU, to SGY, Output to Petrel
%Import to Petrel, Export the proper SEGY in Petrel :)
% -- dear future self, just kill yourself % 2-Oct-2014
% I got a feeling that actually IL and XL is the other way around, but ...

%clear all;
clc

tic;
%p=load('data.ascii');
toc;

%variable
%bosok tenan
path1 = getenv('PATH');
path1 = [path1 ':/usr/local/SU/bin'];
setenv('PATH', path1);
%bosok stop here


nx=801;
nz=801;
ny=187; %y is vertical time as per sofi
delta=25;
deltaT=0.25;
%var end here

%reshape
q=reshape(p,nx,nz,ny);

for line=1:nx
%line=201;
    line
    r=q(line,1:nx,:); %tolol kebalik
    s=reshape(r,nx,ny);
    seis=s'.*1000;
    %figure(1);
    %imagesc(seis);title(num2str(line));
    %data start from 0,0
    sx=(line.*delta)-delta;
    sy=[0:nx-1].*delta;

    %output
    filenametmp=strcat('datadir/tmp.line',num2str(line),'.su');
    filenameout=strcat('datadir/line',num2str(line),'.su');

    %prefer to use this, but not working
    %WriteSu(filename,seis,'dt',deltaT,'Inline3D',InLine,'Crossline3D',XLine,'c
    %dpX',X,'cdpY',Y);

    make_su_file(filenametmp,seis,delta,[1:nx]);

    %set basic header
    %only set, sx, and sy, hopefully petrel will regenerate
    command1=strcat('sushw<',filenametmp,' key=sx,sy,ep,cdp a=',num2str(sx),',',num2str(0),',',num2str(line),',1',' b=0,25,0,1>',filenameout);

    system([command1]);
    !rm *datadir/tmp*
end
close all
!cat datadir/*.su > tmp.merge.su
!susort < tmp.merge.su sx sy > tmp.ovt.su
!segyhdrs < tmp.ovt.su > ovt.su
!surange < ovt.su > range.txt
!segywrite tape=ovt.segy < ovt.su
