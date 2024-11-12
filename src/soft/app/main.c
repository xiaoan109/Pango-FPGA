/*
 * @FilePath       : \pangoPRJ\RISC-V\rtl\SparrowRV\bsp\bsp_app\app\main.c
 * @Author         : zkwang2001 1922601163@qq.com
 * @CreateDate     : 24-10-22
 * @LastEditors    : zkwang2001 1922601163@qq.com
 * @LastEditTime   : 24-10-30
 * Version        :
 * @Description    : 
 *                  
 * 
 * Parameter       :
 *                  
 * 
 * IO Port         :
 *                  
 * 
 * Modification History
 *    Date   |   Author   |   Version   |   Change Description
 * ==============================================================================
 *  23-08-24 |     NJU    |     0.1     | Original Version
 *                  
 * 
 */
#include "system.h"
#define LEN  10
#define CMD_LEN 5
#define PARAM_LEN 4 
    //清空数组
    void clear_cmd();
    uint32_t get_param();
//测试
    void get_cmd(uint8_t *cmd);

int main()
{
    init_uart0_printf(115200,UART0_TX);//设置波特率
    printf("%s", "Hello world SparrowRV\r\n");
    printf("%s", "--------------\r\n");
    fpioa_perips_in_set(UART0_RX, UART0_RX);//FPIOA[0]为RX
    uint8_t buf[LEN];
    uint32_t amp = 0;
    uint32_t freq = 0;
    uint32_t min = 0;
    uint32_t phase = 0;
    dds_set_freq(144611693);
    dso_set_v_scale(0x12);

    while(1)
    {

        get_cmd(&buf[0]);
        printf("cmd get %c%c%c \r\n",buf[0],buf[1],buf[2]);
        uint32_t param_value = get_param(&buf[5]);
//        uint32_t param_value = 0;
        // buf  = 'cmdxx[xxxx]'
        if(buf[0] == 'c' && buf[1] == 'm' && buf[2]=='d'){
            switch(buf[3]){
                case '1': // dds
                    switch(buf[4]){
                        case '1':
                            dds_set_amp(param_value);
                            break;
                        case '2':
                            param_value = param_value*144611+param_value*7/10;
                            printf("set freq %d",param_value);
                            dds_set_freq(param_value);
                            break;
                        case '3':
                            dds_set_min(param_value);
                            break;
                        case '4':
                            dds_set_phase(param_value);
                            break;
                        case '5': // 获取dds的状态并打印
                            dds_get_state(&amp, &freq, &min, &phase);
                            printf("amp:%d freq:%d min:%d phase:%d\r\n",amp,freq,min,phase);
                            break;
                        case '6':
                            param_value = param_value*144611;
                            param_value = param_value/1000;
                            dds_set_freq(param_value);
                            break;
                        case '7':
                            dds_wavetype(param_value);
                            break;
                        default:
                            break;
                    }
                    printf("cmd is dds, func is %d, value is %d\r\n",buf[4],param_value);
                    break;
                case '2': //dso
                    switch(buf[4]){
                        case '1':
                            dso_set_trig_level(param_value);
                            break;
                        case '2':
                            dso_set_deci_rate(param_value);
                            break;
                        case '3':
                            dso_set_wave_run(param_value);
                            break;
                        case '4':
                            dso_set_trig_edge(param_value);
                            break;
                        case '5':
                            dso_set_v_scale(param_value);
                            break;
                        case '6':
                            dso_set_fft_en(param_value);
                            break;
                        case '7':
                            printf("freq:%d\r\n",dso_get_freq());
                            break;
                        case '8':
                            printf("vpp:%d\r\n",dso_get_vpp());
                            break;
                        case '9':
                            printf("max:%d\r\n",dso_get_max());
                            break;
                        case 'a':
                            printf("min:%d\r\n",dso_get_min());
                            break;
                        case 'b':
                            dso_set_fir_en(param_value);
                            break;
                        case 'c':
                            dso_set_trig_line(param_value);
                            break;
                        default:
                            break;
                    }
                    printf("cmd is dso, func is %d, value is %d\r\n",buf[4],param_value);
                    break;
                case '3':// ila
                        switch(buf[4]){
                        case '1':
                            la_set_data(param_value);
                            break;
                        case '2':
                            la_set_trgen(param_value);
                            break;  
                        case '3':
                            la_set_chnsel(param_value);
                            break;
                        case '4':
                            la_set_modesel(param_value);
                            break;
                        case '5':
                            la_set_freqsel(param_value);
                            break;
                        case '6':
                            la_set_prenum(param_value);
                            break;
                        case '7':
                            printf("data:%d\r\n",la_get_data());
                            break;  
                        case '8':
                            printf("trgen:%d\r\n",la_get_trgen());
                            break;
                        case '9':
                            printf("chnsel:%d\r\n",la_get_chnsel());
                            break;
                        case 'a':
                            printf("modesel:%d\r\n",la_get_modesel());
                            break;
                        case 'b':
                            printf("freqsel:%d\r\n",la_get_freqsel());
                            break;
                        case 'c':
                            printf("prenum:%d\r\n",la_get_prenum());
                            break;
                        case 'd':
                            la_set_uart_en(param_value);
                            break;
                        case 'e':
                            la_set_spi_en(param_value);
                            break;
                        case 'f':
                            la_set_interval(param_value);
                            break;
                        default:
                            break;
                        }
                    break;
                case '4':// eth
                        switch(buf[4]){
                        case '1':
                            eth_dds_set_wave(param_value);
                            break;
                        case '2':
                            eth_dds_set_amp(param_value);
                            break;
                        case '3':
                            param_value = param_value*144611+param_value*7/10;
                            eth_dds_set_freq(param_value);
                            break;
                        case '4':
                            eth_dds_set_min(param_value);
                            break;
                        case '5':
                            eth_dds_set_phsae(param_value);
                            break;
                        case '6':
                            eth_dds_en(param_value);
                            break;
                        case '7':
                            printf("eth dds wave:%d\r\n",eth_dds_get_wave());
                            break;
                        case '8':
                            printf("eth dds amp:%d\r\n",eth_dds_get_amp());
                            break;
                        case '9':
                            printf("eth dds freq:%d\r\n",eth_dds_get_freq());
                            break;
                        case 'a':
                            printf("eth dds min:%d\r\n",eth_dds_get_min());
                            break;
                        case 'b':
                            printf("eth dds phase:%d\r\n",eth_dds_get_phsae());
                            break;
                        case 'c':
                            printf("eth dds en:%d\r\n",eth_dds_get_en());
                            break;
                        case 'd':
                            param_value = param_value*144611;
                            param_value = param_value/1000;
                            eth_dds_set_freq(param_value);
                            break;
                        default:
                            break;
                        }
                    break;
                default:
                    break;
            }
        }
        // delay_mtime_us(1000000);//延迟一秒
        clear_cmd(buf,LEN);
        }

    return 0;
}

void get_cmd(uint8_t *cmd){
    int j = 0 ;
    while(j<CMD_LEN+PARAM_LEN){
        if(uart_recv_flg(UART0)){
            cmd[j] = uart_recv_date(UART0);
            j++;
        }
    }
};


void clear_cmd(uint8_t *cmd,int len){
    for(int i = 0; i<len; i++){
        cmd[i] = 0;
    }
    printf("cmd completed\r\n");
};

uint32_t get_param(uint8_t *value){
    int i = 0 ;
    uint8_t num = 0;
    uint32_t param = 0;

    for (;i<PARAM_LEN;i++){
        num = *(value+i)-'0';
        param = num+param*10;
    }

    printf("param_value is %d\r\n",param);
    return param;
};
