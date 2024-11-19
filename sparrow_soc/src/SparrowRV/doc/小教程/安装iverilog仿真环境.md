# 安装iverilog仿真环境

## 简介
iverilog全程Icarus Verilog是一款开源、免费、跨平台的Verilog/SV仿真器。仿真流程很简单，RTL设计经过编译，转化为`vvp`中间文件，然后使用`vvp命令`执行仿真，输出波形文件和打印信息。  
gtkwave是一款开源、免费、跨平台的查看波形文件的工具软件，通常与iverilog一起安装。  

## Windows平台
[视频版教程](https://www.bilibili.com/video/BV1Se4y1C7sZ)  
进入网页http://bleyer.org/icarus/  
这里有打包好的Windows版iverilog+gtkwave安装包，简单易用  
点击`iverilog-v12-20220611-x64_setup [18.2MB]`，下载并打开 ，安装路径随便选  
`Add executable folder(s) to the user PATH`一定要勾选！！！  
花一点时间安装  
打开`cmd/命令提示符/shell终端`，输入`iverilog`回车，显示如下信息表示iverilog安装成功  
```
iverilog: no source files.

Usage: iverilog [-EiSuvV] [-B base] [-c cmdfile|-f cmdfile]
                [-g1995|-g2001|-g2005|-g2005-sv|-g2009|-g2012] [-g<feature>]
                [-D macro[=defn]] [-I includedir] [-L moduledir]
                [-M [mode=]depfile] [-m module]
                [-N file] [-o filename] [-p flag=value]
                [-s topmodule] [-t target] [-T min|typ|max]
                [-W class] [-y dir] [-Y suf] [-l file] source_file(s)

See the man page for details.
```  
打开`cmd/命令提示符/shell终端`，输入`gtkwave`回车，打开gtkwave软件窗口表示安装成功   

## Linux平台
本教程的命令仅适用于自带`apt包管理器`的Linux发行版，如Debian、乌班图、Deepin/UOS等  
**不推荐**直接使用`sudo apt install iverilog`安装`iverilog`，因为版本可能会很老。  
但是可以使用`sudo apt install gtkwave`安装`gtkwave`  
我提供了国内镜像仓库，稳定快捷，默认安装`v12稳定版`，推荐依次执行以下命令编译安装iverilog。  
```
sudo apt install make git gtkwave gcc g++ bison flex gperf autoconf
git clone -b v12_0 --depth=1 https://gitee.com/xiaowuzxc/iverilog/
cd iverilog
sh autoconf.sh
./configure
make
sudo make install
cd ..
rm -rf iverilog/
```
打开终端，输入`iverilog`回车，显示如下信息表示iverilog安装成功  
```
iverilog: no source files.

Usage: iverilog [-EiSuvV] [-B base] [-c cmdfile|-f cmdfile]
                [-g1995|-g2001|-g2005|-g2005-sv|-g2009|-g2012] [-g<feature>]
                [-D macro[=defn]] [-I includedir] [-L moduledir]
                [-M [mode=]depfile] [-m module]
                [-N file] [-o filename] [-p flag=value]
                [-s topmodule] [-t target] [-T min|typ|max]
                [-W class] [-y dir] [-Y suf] [-l file] source_file(s)

See the man page for details.
```  
打开终端，输入`gtkwave`回车，打开gtkwave软件窗口表示安装成功   


## 如何使用
iverilog只有命令行交互界面，没有图形化GUI交互界面。  
大部分情况下，iverilog都是使用命令行驱动的，具体命令可以看[iverilog官方手册](https://steveicarus.github.io/iverilog/)，需要配合翻译工具阅读  
也可以依葫芦画瓢，改一改现有的工程[LCD1602显示驱动模组](https://gitee.com/xiaowuzxc/LCD1602-display-IP/)  
