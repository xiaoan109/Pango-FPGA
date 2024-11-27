clc;                    %清除命令行命令
clear all;              %清除工作区变量,释放内存空间
F1=1;                   %信号频率
Fs=2^12;                %采样频率
P1=0;                   %信号初始相位
N=2^12;                 %采样点数
t=[0:1/Fs:(N-1)/Fs];    %采样时刻
ADC=2^7 - 1;            %直流分量
A=2^7;                  %信号幅度
%生成方波信号
s=A*square(2*pi*F1*t + pi*P1/180) + ADC;
plot(s);                %绘制图形
%创建mif文件
fild = fopen('squ_wave_4096x8.dat','a');

for i = 1:N
    s0(i) = round(s(i));    %对小数四舍五入以取整
    if s0(i) <0             %负1强制置零
        s0(i) = 0
    end
    fprintf(fild, '%x\n',s0(i));      %数据写入,换行
end

fclose(fild);