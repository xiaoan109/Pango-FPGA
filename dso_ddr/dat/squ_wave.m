clc;                    %�������������
clear all;              %�������������,�ͷ��ڴ�ռ�
F1=1;                   %�ź�Ƶ��
Fs=2^12;                %����Ƶ��
P1=0;                   %�źų�ʼ��λ
N=2^12;                 %��������
t=[0:1/Fs:(N-1)/Fs];    %����ʱ��
ADC=2^7 - 1;            %ֱ������
A=2^7;                  %�źŷ���
%���ɷ����ź�
s=A*square(2*pi*F1*t + pi*P1/180) + ADC;
plot(s);                %����ͼ��
%����mif�ļ�
fild = fopen('squ_wave_4096x8.dat','a');

for i = 1:N
    s0(i) = round(s(i));    %��С������������ȡ��
    if s0(i) <0             %��1ǿ������
        s0(i) = 0
    end
    fprintf(fild, '%x\n',s0(i));      %����д��,����
end

fclose(fild);