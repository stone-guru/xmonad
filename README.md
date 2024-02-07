# XMonad 配置
## 整体过程

 - 个人配置程序编译后生产 `xmonad` 的可运行程序是一个完整
   的窗口管理器，一般放在`.xmonad/`下面
 - 然后需要进行系统性配置，使得登陆后能够启动这个窗口管理器。如果是
   console方式登陆，自己startx就比较简单。但是现在都用gdm这样的图形登
   陆，就需要做一点配置让gdm能找到并运行上述的这个窗口管理器程序。
   
## 系统级配置

 在debian 12 下的配置如下：
   - 给gdm增加登陆后的session选择，让其能运行xmonad。文件为：
     `/usr/share/xsessions/xmonad.desktop`，内容如下：
   
   ```console
   [Desktop Entry]
   Name=XMonad
   Comment=Lightweight tiling window manager
   Exec=xmonad-session
   Type=XSession
   ```
  - 这个Exec项的xmonad-session原本也是没有的。创建
    `/usr/bin/xmoand-session`，内容为：
    
    ```shell
    !/bin/bash
    if [ -r ".xmonad/xmonad-session-rc" ]
    then
    . .xmonad/xmonad-session-rc
    fi
    exec xmonad "$@"
    ```
    它做两件事，一是执行登陆用户下的初始化脚本，然后启动`xmonad`这个程序。
    
   - 全局xmonad与个人xmonad
   
      在xmonad的默认`main`是这样处理的，它会检查用户是否有一个
     `.xmonad/xmonad.hs`文件或`build`脚本。若有，就会进行编译并启动这
     个程序来作为窗口管理器。
     
     当然可以直接在上面的`xmonad-session`中修改为`exec`用户`.xmonad`下
     的程序，但是从完备的角度来讲这样这样不是很合理，因为
     `xmonad-session`是全局安装，应该也搭配有全局的`xmonad`这个窗口管
     理器。所以，下面的`stack`项目里有两个输出，一个是没有任何个性化配置
     的默认`xmonad`，另一个是进行了定制的。 编译后将`xmonad-def`复制到
     `/usr/local/bin/`这样的全局路径，并命名为`xmonad`就好。
     
     这样，启动顺序就是完整的了：
     ```console
     gdm login  # select XMonad session
     exec xmonad # xmonad-session 里
     xmonad # 这个是全局xmonad
     xmonad launch user xmonad # 如果没有，就自己全默认执行
     ```
     
     其中，user的程序在xmonad中有一个默认名称 `xmonad-x86_64-linux`，
     这个会由xmonad调用build时传递进来。
    
## 配置文件与自动重加载

两件事情，一就是一个haskell的项目，二是让xmonad能够在配置修改后，自己编译自己加载自己

### 项目
 - 位置 `.xmond`, 按stack来组织就好，只留了一个`src`里的一个`xmonad.hs`来作配置
 - 重编译并加载由 `xmonad` 可认识的 `build`脚本来执行。
   ```shell
   #!/bin/sh
   set -e
   stack build :xmonad-exe --verbosity error
   stack install :xmonad-exe --local-bin-path bin/ --verbosity error
   mv bin/xmonad-exe "$1"
   ```
   其中 `xmonad-exe`是项目里编译生成的程序名，在`package.yaml`中指定的。
   
 - `xmonad.hs`里面再安排上一个`reload`命令
 
 ```haskell
 reloadXmonad = "xmonad --recompile; xmonad --restart; " ++
  "xmessage -center -geometry 300x100 'XMonad reloaded'"
  
  keys = [others, ((modm              , xK_q     ), spawn reloadXmonad)]
 ```

 
## 可以搭配使用的其它程序

- dmenu 顶部菜单
- gmrun 弹框命令快速补齐

