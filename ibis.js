var fs=require("fs");
var cp=require("child_process");
var discord=require("discord.js");
var bot=new discord.Client();

var cfg=JSON.parse(fs.readFileSync("ibiscf.json"));
for(var i=0;i<cfg.cmds.length;i++){
    cfg.cmds[i][0]=new RegExp(cfg.cmds[i][0]);
}

var excom = function (cstr, msg){
    var res="";
    var cmd = cp.spawn(cstr, [msg.content, msg.author.username, msg.author.toString()]);
    cmd.stdout.on('data', function(data){
        res=res.concat(data.toString());
    });
    cmd.on('close', function(code){
        msg.reply(res);
    });
};

bot.on('message', function(msg){
    for(var i=0;i<cfg.cmds.length;i++){
        if(cfg.cmds[i][0].test(msg.content)){
            excom(cfg.cmds[i][1], msg);
        }
    }
});

bot.login(cfg.token);
