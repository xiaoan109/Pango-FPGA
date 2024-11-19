'''
#生成s0-s7
i=0
while i<8:
    print(r'    //s'+str(i))
    print(r'    output wire                 s'+str(i)+'_icb_cmd_'+'valid'+',')
    print(r'    input  wire                 s'+str(i)+'_icb_cmd_'+'ready'+',')
    print(r'    output wire [`MemAddrBus]   s'+str(i)+'_icb_cmd_'+'addr '+',')
    print(r'    output wire                 s'+str(i)+'_icb_cmd_'+'read '+',')
    print(r'    output wire [`MemBus]       s'+str(i)+'_icb_cmd_'+'wdata'+',')
    print(r'    output wire [3:0]           s'+str(i)+'_icb_cmd_'+'wmask'+',')
    print(r'    input  wire                 s'+str(i)+'_icb_rsp_'+'valid'+',')
    print(r'    output wire                 s'+str(i)+'_icb_rsp_'+'ready'+',')
    print(r'    input  wire                 s'+str(i)+'_icb_rsp_'+'err  '+',')
    print(r'    input  wire [`MemBus]       s'+str(i)+'_icb_rsp_'+'rdata'+',')
    i+=1
'''
'''
i=0
while i<8:
    print(r'assign s'+str(i)+'_icb_cmd_valid = {1{cmd_sel['+str(i)+']}} & master_icb_cmd_valid;')
    i+=1
i=0
while i<8:
    print(r'| {1{cmd_sel['+str(i)+']}} & s'+str(i)+'_icb_cmd_ready')
    i+=1
i=0
while i<8:
    print(r'assign s'+str(i)+'_icb_cmd_addr  = master_icb_cmd_addr ;')
    i+=1
i=0
while i<8:
    print(r'assign s'+str(i)+'_icb_cmd_read  = master_icb_cmd_read ;')
    i+=1
i=0
while i<8:
    print(r'assign s'+str(i)+'_icb_cmd_wdata = master_icb_cmd_wdata;')
    i+=1
i=0
while i<8:
    print(r'assign s'+str(i)+'_icb_cmd_wmask = master_icb_cmd_wmask;')
    i+=1
'''
i=0
while i<16 :
    print("28'd"+str(i*4)+"   : plic_prt["+str(i)+"] <= plic_icb_cmd_wdata[1:0];")
    i=i+1

i=0
while i<16 :
    print("28'd"+str(i*4)+"   : plic_icb_rsp_rdata <= {30'h0, plic_prt["+str(i)+"]};")
    i=i+1
