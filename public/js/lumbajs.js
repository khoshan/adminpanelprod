function post_to_url(url, params) {
  var form = document.createElement('form');
  form.action = url;
  form.method = 'POST';
  for (var i in params) {
    if (params.hasOwnProperty(i)) {
      var input = document.createElement('input');
      input.type = 'hidden';
      input.name = i;
      input.value = params[i];
      form.appendChild(input);
    }
  }
  form.submit(function(e){ alert("Submitting Form"); });
  $("body").append(form);
  form.submit();
}

function exportxlsx(){
  $.ajax({
    url: "/lumba/export",
    data: {  },
    type: 'get',
    success: function(data) {
      alert("export successful");
    },
    error: function(data){
      alert("export fail");
    }
  });
}

function eliminateDuplicates(arr) {
  var i,
      len=arr.length,
      out=[],
      obj={};
  for (i=0;i<len;i++) {
    obj[arr[i]]=0;
  }
  for (i in obj) {
    out.push(i);
  }
  return out;
}

function exportfile(x, doexport, confirmpassword){
  if((x != 16) && ($( "#version" ).val() === "")) {
    alert("Please choose game version to export");
    return false;
  }
  if (!doexport) {
    $( "#dialog-form" ).dialog( "open" );
    $( "#confirmpasswordbtn" ).click(function() {
      exportfile(x, true, $( "#password" ).val());
      $( "#dialog-form" ).dialog( "close" );
    });
  }
  else {
    /*campaign: x = 1*/
    if (x == 1){
      post_to_url("/lumba/gamedata/campaign?exportcampaign=exportcampaign", { exportcampaign: "exportcampaign",exportserver: "development", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })
    }
    /*combat: x = 2*/
    else if (x == 2) {
      post_to_url("/lumba/gamedata/combat_units?exportcombatunit=exportcombatunit", { exportcombatunit: "exportcombatunit", exportserver: "development", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })
    }
    /*unit level: x = 3*/
    else if (x == 3) {
      post_to_url("/lumba/gamedata/unit_levels?exportunitlevels=exportunitlevels", { exportunitlevels: "exportunitlevels", exportserver: "development", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })
    }
    /*defensive building: x = 4*/
    else if (x == 4) {
      post_to_url("/lumba/gamedata/defensive_building?exportdefensivebuilding=exportdefensivebuilding", { exportdefensivebuilding: "exportdefensivebuilding", exportserver: "development", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })
    }
    /*defensive building level: x = 5*/
    else if (x == 5) {
      post_to_url("/lumba/gamedata/defensive_buildings_level?exportdefensivebuildingslevel=exportdefensivebuildingslevel", { exportdefensivebuildingslevel: "exportdefensivebuildingslevel", exportserver: "development", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })
    }
    /*resource variable: x = 6*/
    else if (x == 6) {
      post_to_url("/lumba/gamedata/resources_building_variables?exportresourcesbuildingvariables=exportresourcesbuildingvariables", { exportresourcesbuildingvariables: "exportresourcesbuildingvariables", exportserver: "development", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })
    }
    /*army: x = 7*/
    else if (x == 7) {
      post_to_url("/lumba/gamedata/army_building?exportarmybuilding=exportarmybuilding", { exportarmybuilding: "exportarmybuilding", exportserver: "development", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })
    }
    /*other building: x = 8*/
    else if (x == 8) {
      post_to_url("/lumba/gamedata/other_buildings?exportotherbuildings=exportotherbuildings", { exportotherbuildings: "exportotherbuildings", exportserver: "development", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })
    }
    /*town hall: x = 9*/
    else if (x == 9) {
  post_to_url("/lumba/gamedata/town_hall_level?exporttownhalllevel=exporttownhalllevel", { exporttownhalllevel: "exporttownhalllevel", exportserver: "development", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })
}
/*decoration*/
else if (x == 10) {
  post_to_url("/lumba/gamedata/decoration?exportdecoration=exportdecoration", { exportdecoration: "exportdecoration",exportserver: "development", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })
}
/*spell*/
else if (x == 11) {
  post_to_url("/lumba/gamedata/spell?exportspell=exportspell", { exportspell: "exportspell", exportserver: "development", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })
}
/*spell level*/
else if (x == 12) {
  post_to_url("/lumba/gamedata/spell_level?exportspelllevel=exportspelllevel", { exportspelllevel: "exportspelllevel", exportserver: "development", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })
}
/*obstacle*/
else if (x == 13) {
  post_to_url("/lumba/gamedata/obstacles?exportobstacles=exportobstacles", { exportobstacles: "exportobstacles", exportserver: "development", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })
}
/*trophy*/
else if (x == 14) {
  post_to_url("/lumba/gamedata/trophy?exporttrophy=exporttrophy", { exporttrophy: "exporttrophy", exportserver: "development", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })
}
/*Achivement*/
else if (x == 15) {
  post_to_url("/lumba/gamedata/acheivements?exportacheivements=exportacheivements", { exportacheivements: "exportacheivements", exportserver: "development", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })
}
/*setting*/
else if (x == 16) {
  post_to_url("/lumba/gamedata/setting?exportsetting=exportsetting", { exportsetting: "exportsetting", exportserver: "development", confirmpassword: confirmpassword })
} 
/*setting info*/
else if (x == 17) {
  post_to_url("/lumba/gamedata/setting?exportsettinginfo=exportsettinginfo", { exportsettinginfo: "exportsettinginfo", exportserver: "development", game_version: $( "#version" ).val(), purchase_products: $( "#purchase_products" ).val(), confirmpassword: confirmpassword })
}
/*bundle: 20*/
if (x == 20){
  post_to_url("/lumba/bundle?exportbundle=exportbundle", { exportbundle: "exportbundle", exportserver: "development", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })
}
/*arabic 21*/
if (x == 21){
  post_to_url("/lumba/setlang?exportar=exportar", { exportar: "exportar", exportserver: "development", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })
}
/*english 22*/
if (x == 22){
  post_to_url("/lumba/setlang?exporten=exporten", { exporten: "exporten", exportserver: "development", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })
}
}
}

function exportfileproduction(x, doexport, confirmpassword){
  if((x != 16) && ($( "#version" ).val() === "")) {
      alert("Please choose game version to export");
      return false;
    }
if (!doexport) {
$( "#dialog-form" ).dialog( "open" );
$( "#confirmpasswordbtn" ).click(function() {
  exportfileproduction(x, true, $( "#password" ).val());
  $( "#dialog-form" ).dialog( "close" );
});
}
else {
  /*campaign: x = 1*/
  if (x == 1){post_to_url("/lumba/gamedata/campaign?exportcampaign=exportcampaign", { exportcampaign: "exportcampaign", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })}
  /*combat: x = 2*/
  else if (x == 2) {  post_to_url("/lumba/gamedata/combat_units?exportcombatunit=exportcombatunit", { exportcombatunit: "exportcombatunit", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })}
  /*unit level: x = 3*/
  else if (x == 3) {  post_to_url("/lumba/gamedata/unit_levels?exportunitlevels=exportunitlevels", { exportunitlevels: "exportunitlevels", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })}
  /*defensive building: x = 4*/
  else if (x == 4) {  post_to_url("/lumba/gamedata/defensive_building?exportdefensivebuilding=exportdefensivebuilding", { exportdefensivebuilding: "exportdefensivebuilding", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })}
  /*defensive building level: x = 5*/
  else if (x == 5) {  post_to_url("/lumba/gamedata/defensive_buildings_level?exportdefensivebuildingslevel=exportdefensivebuildingslevel", { exportdefensivebuildingslevel: "exportdefensivebuildingslevel", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })}
  /*resource variable: x = 6*/
  else if (x == 6) {  post_to_url("/lumba/gamedata/resources_building_variables?exportresourcesbuildingvariables=exportresourcesbuildingvariables", { exportresourcesbuildingvariables: "exportresourcesbuildingvariables", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })}
  /*army: x = 7*/
  else if (x == 7) {  post_to_url("/lumba/gamedata/army_building?exportarmybuilding=exportarmybuilding", { exportarmybuilding: "exportarmybuilding", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })}
  /*other building: x = 8*/
  else if (x == 8) {  post_to_url("/lumba/gamedata/other_buildings?exportotherbuildings=exportotherbuildings", { exportotherbuildings: "exportotherbuildings", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })}
  /*town hall: x = 9*/
  else if (x == 9) {  post_to_url("/lumba/gamedata/town_hall_level?exporttownhalllevel=exporttownhalllevel", { exporttownhalllevel: "exporttownhalllevel", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })}
  /*decoration*/
  else if (x == 10) {  post_to_url("/lumba/gamedata/decoration?exportdecoration=exportdecoration", { exportdecoration: "exportdecoration", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })}
  /*spell*/
  else if (x == 11) {  post_to_url("/lumba/gamedata/spell?exportspell=exportspell", { exportspell: "exportspell", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })}
  /*spell level*/
  else if (x == 12) {  post_to_url("/lumba/gamedata/spell_level?exportspelllevel=exportspelllevel", { exportspelllevel: "exportspelllevel", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })}
  /*obstacle*/
  else if (x == 13) {  post_to_url("/lumba/gamedata/obstacles?exportobstacles=exportobstacles", { exportobstacles: "exportobstacles", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })}
  /*trophy*/
  else if (x == 14) {  post_to_url("/lumba/gamedata/trophy?exporttrophy=exporttrophy", { exporttrophy: "exporttrophy", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })}
  /*Achivement*/
  else if (x == 15) {  post_to_url("/lumba/gamedata/acheivements?exportacheivements=exportacheivements", { exportacheivements: "exportacheivements", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })}
  /*setting*/
  else if (x == 16) {  post_to_url("/lumba/gamedata/setting?exportsetting=exportsetting", { exportsetting: "exportsetting", exportserver: "production", confirmpassword: confirmpassword })} 
  /*setting info*/
  else if (x == 17) {  post_to_url("/lumba/gamedata/setting?exportsettinginfo=exportsettinginfo", { exportsettinginfo: "exportsettinginfo", exportserver: "production", game_version: $( "#version" ).val(),purchase_products: $( "#purchase_products" ).val(), confirmpassword: confirmpassword })}
  /*bundle: 20*/
  if (x == 20){  post_to_url("/lumba/bundle?exportbundle=exportbundle", { exportbundle: "exportbundle", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })}
  /*arabic 21*/
  if (x == 21){  post_to_url("/lumba/setlang?exportar=exportar", { exportar: "exportar", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })}
  /*english 22*/
  if (x == 22){  post_to_url("/lumba/setlang?exporten=exporten", { exporten: "exporten", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })}
  /*profanity arabic 23*/
  if (x == 23){  post_to_url("/lumba/profanity?exportarprof=exportarprof", { exportarprof: "exportarprof", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })  }
/*profanity english 24*/
  if (x == 24){  post_to_url("/lumba/profanity?exportenprof=exportenprof", { exportenprof: "exportenprof", exportserver: "production", game_version: $( "#version" ).val(), confirmpassword: confirmpassword })  }
}
}

var pkIdAr = [];

/* Copy content admin user*/
function copyContentAdminUser(x){
var Sender = window.event.srcElement;
var index = 0;
var pkIdArray = [];
var usernameArray = [];
var passwordArray = [];
var emailArray = [];

$('#tbladminusers .adminIDCell').each(function(indexx, value)
{
if ($(this).text() === x){ index = indexx;}
pkIdArray.push($(this).text());
});
// copy username
$('#tbladminusers .admin_username').each(function()
{
usernameArray.push($(this).text());
});
// copy email
$('#tbladminusers .admin_useremail').each(function()
{
emailArray.push($(this).text());
});

//copy password
$('#tbladminusers .admin_userpassword').each(function()
{
passwordArray.push($(this).text());
});
if (Sender.id === "editadminuser"){
post_to_url("/lumba/adminUsers", { actionupdate: "update", admin_id: pkIdArray[index], admin_name: usernameArray[index], admin_password: passwordArray[index], admin_email: emailArray[index] })
}
if(Sender.name === "deleteadminuser"){
post_to_url("/lumba/adminUsers", {deleteadminuser: x})
}
return true;
}

/* Copy content tribe*/
function copyContentTribe(x){
  var Sender = window.event.srcElement;
  var index = 0;
  var tribenameArray = [];
  var tribeIdArray = [];

  $('#tbltribe .tribe_id').each(function(indexx, value) {
    if ($(this).text() === x){ index = indexx;}
  });

  $('#tbltribe .tribe_name').each(function(indexx, value) {
    tribenameArray.push($(this).text());
  });
  if (Sender.id === "edittribe"){
    post_to_url("/lumba/tribe", { actionupdate: "updatetribe", tribe_id: x, tribe_name: tribenameArray[index] })
  }
  return true;
}

function copyContentBundle(x){
        var Sender = window.event.srcElement;
        var index = 0;
        var bundlepkIdArray = []; var bundlekeyArray = []; var bundlevalueArray = [];

        $('#tblsetbundle .bundlepkId').each(function(indexx, value){
        if ($(this).text() === x){ index = indexx;}
          bundlepkIdArray.push($(this).text());
        });

        $('#tblsetbundle .bundlekey').each(function(){bundlekeyArray.push($(this).text());});
        $('#tblsetbundle .bundlevalue').each(function(){bundlevalueArray.push($(this).text());});

        if (Sender.name === "editbundle"){
          post_to_url("/lumba/bundle", { actionupdate: "update", pkID: x, bundlekey: bundlekeyArray[index], bundlevalue: bundlevalueArray[index]})
        }
        if(Sender.name === "editmultibundle") {
          pkIdAr = eliminateDuplicates(pkIdAr);
          bundlekeyA = []; bundlevalueA = [];
          for(var i = 0; i < pkIdAr.length; i++){
            for (var j = 0; j < bundlepkIdArray.length; j++){
              if (pkIdAr[i] === bundlepkIdArray[j]){
                bundlekeyA.push(bundlekeyArray[j]);
                bundlevalueA.push(bundlevalueArray[j]);
              }
            }
          }
          post_to_url("/lumba/bundle", { editmultibundle: "editmultibundle", pkId: pkIdAr, bundlekey: JSON.stringify(bundlekeyA), bundlevalue: JSON.stringify(bundlevalueA)})
        }
        return false;
}

function copyContentSetting(x){
        var Sender = window.event.srcElement;
        var index = 0;
        var settingSaveIntervalArray = [];
        var settingGameVersionArray = []; var settingComicVersionAndrArray = []; var settingComicVersionIOSArray = []; var settingNextGameVersionArray = []; var settingforcedUpdateClanIdsArray = [];
        var settingandroidAppUrl_EN_Array = []; var settingiosAppUrl_EN_Array = []; var settingsoftMovedVersions1Array = []; var settingsoftMovedVersions2Array = []; var settingresourceFileNamesArray = [];
        var settingandroidAppUrl_AR_Array = []; var settingiosAppUrl_AR_Array = []; var settingmaintainVersionsArray = []; settingsubVersionsArray = []; settingsubVersionsClanIdArray = [];
        var settingEnableGhostsArray = [];

        $('#tblsetting .settingpkID').each(function(indexx, value){
        if ($(this).text() === x){ index = indexx;}
        });

        $('#tblsetting .settingSaveInterval').each(function(){settingSaveIntervalArray.push($(this).text());});
        $('#tblsetting .settingGameVersion').each(function(){settingGameVersionArray.push($(this).text());});
        $('#tblsetting .settingComicVersionIOS').each(function(){settingComicVersionIOSArray.push($(this).text());});
        $('#tblsetting .settingComicVersionAndr').each(function(){settingComicVersionAndrArray.push($(this).text());});
        $('#tblsetting .settingNextGameVersion').each(function(){settingNextGameVersionArray.push($(this).text());});
        $('#tblsetting .settingmaintainVersions').each(function(){settingmaintainVersionsArray.push($(this).text());});
        $('#tblsetting .settingsubVersions').each(function(){settingsubVersionsArray.push($(this).text());});
        $('#tblsetting .settingsubVersionsClanIds').each(function(){settingsubVersionsClanIdArray.push($(this).text());});
        $('#tblsetting .settingforcedUpdateClanIds').each(function(){settingforcedUpdateClanIdsArray.push($(this).text());});
        $('#tblsetting .settingandroidAppUrl_en').each(function(){settingandroidAppUrl_EN_Array.push($(this).text());});
        $('#tblsetting .settingiosAppUrl_en').each(function(){settingiosAppUrl_EN_Array.push($(this).text());});
        $('#tblsetting .settingandroidAppUrl_ar').each(function(){settingandroidAppUrl_AR_Array.push($(this).text());});
        $('#tblsetting .settingiosAppUrl_ar').each(function(){settingiosAppUrl_AR_Array.push($(this).text());});

        $('#tblsetting .settingsoftMovedVersions1').each(function(){settingsoftMovedVersions1Array.push($(this).text());});
        $('#tblsetting .settingsoftMovedVersions2').each(function(){settingsoftMovedVersions2Array.push($(this).text());});
        $('#tblsetting .settingresourceFileNames').each(function(){settingresourceFileNamesArray.push($(this).text());});
        //add by sonhg
        $('#tblsetting .settingEnableGhost').each(function(){settingEnableGhostsArray.push($(this).text());});
        if (Sender.name === "editsetting"){
          post_to_url("/lumba/gamedata/setting", { actionupdate: "update", pkID: x, settSaveInterval: settingSaveIntervalArray[index], settGameVersion: settingGameVersionArray[index], settComicVersionIOS: settingComicVersionIOSArray[index], settComicVersionAndr: settingComicVersionAndrArray[index], settandroidAppUrl_en: settingandroidAppUrl_EN_Array[index], settiosAppUrl_en: settingiosAppUrl_EN_Array[index], settandroidAppUrl_ar: settingandroidAppUrl_AR_Array[index], settiosAppUrl_ar: settingiosAppUrl_AR_Array[index],  settNextGameVersion: settingNextGameVersionArray[index], settmaintainVersions: settingmaintainVersionsArray[index], settingsubVersions: settingsubVersionsArray[index], settingsubVersionsClanIds: settingsubVersionsClanIdArray[index], settforcedUpdateClanIds: settingforcedUpdateClanIdsArray[index], settsoftMovedVersions1: settingsoftMovedVersions1Array[index], settsoftMovedVersions2: settingsoftMovedVersions2Array[index], settresourceFileNames: settingresourceFileNamesArray[index], settEnableGhost: settingEnableGhostsArray[index]})
        }
        if(Sender.name === "deleteid"){
          post_to_url("/lumba/gamedata/setting", {deleteid: x})
        }
        return false;
}

function copyContentSettingInfo(){
        var Sender = window.event.srcElement;
        var index = 0;
        var settingInfoSaveIntervalArray = [];
        var settingInfoIapRatioArray = [];
        var settinggemrangeforcalculatetimeArray = [];
        var settinggoldwaterrangeArray = [];
        var settingoilrangeArray = [];
        var settinggemrangeforcalculateresourceArray = [];
        var settingTERM_SERVICE_LINKArray = [];
        var settingTERM_SERVICE_LINK_EN_Array = [];
        var settingTERM_SERVICE_LINK_AR_Array = [];
        var settingPOLICY_LINKArray = [];
        var settingPOLICY_LINK_EN_Array = [];
        var settingPOLICY_LINK_AR_Array = [];
        var settingFACEBOOK_LINKArray = [];
        var settingTWITTER_LINKArray = [];
        var settingCOME_BACK_NOTIFICATION_DURATIONArray = [];
        var settingSIGNATURE_ORDERArray = [];
        var settingSHOULD_FIND_SFS_SERVERArray = [];
        var settingGAME_MAINTAINArray = [];
        var settingENABLE_LOGArray = [];
    var settingENABLE_ADJUST_LOGArray = [];
        var settingMAX_LOGArray = [];
        var settingCHAT_INTERVALArray = [];
        var settingENABLE_IAP_LOGArray = [];
        var settingSEND_TROOP_SECONDSArray = [];
        var settingSAVE_HISTORY_MINUTESArray = [];
        var settingPING_INTERVAL_SECONDSArray = [];
        var settingREQUEST_TIME_OUTArray = [];

        $('#tblsettinginfo .settinginfoSaveInterval').each(function(){settingInfoSaveIntervalArray.push($(this).text());});
        $('#tblsettinginfo .settinginfoiapratio').each(function(){settingInfoIapRatioArray.push($(this).text());});
        $('#tblsettinginfo .settinggemrangeforcalculatetime').each(function(){settinggemrangeforcalculatetimeArray.push($(this).text());});
        $('#tblsettinginfo .settinggoldwaterrange').each(function(){settinggoldwaterrangeArray.push($(this).text());});
        $('#tblsettinginfo .settingoilrange').each(function(){settingoilrangeArray.push($(this).text());});
        $('#tblsettinginfo .settinggemrangeforcalculateresource').each(function(){settinggemrangeforcalculateresourceArray.push($(this).text());});
        $('#tblsettinginfo .settingTERM_SERVICE_LINK_EN').each(function(){settingTERM_SERVICE_LINK_EN_Array.push($(this).text());});
        $('#tblsettinginfo .settingTERM_SERVICE_LINK_AR').each(function(){settingTERM_SERVICE_LINK_AR_Array.push($(this).text());});
        $('#tblsettinginfo .settingPOLICY_LINK_EN').each(function(){settingPOLICY_LINK_EN_Array.push($(this).text());});
        $('#tblsettinginfo .settingPOLICY_LINK_AR').each(function(){settingPOLICY_LINK_AR_Array.push($(this).text());});
        $('#tblsettinginfo .settingFACEBOOK_LINK').each(function(){settingFACEBOOK_LINKArray.push($(this).text());});
        $('#tblsettinginfo .settingTWITTER_LINK').each(function(){settingTWITTER_LINKArray.push($(this).text());});
        $('#tblsettinginfo .settingCOME_BACK_NOTIFICATION_DURATION').each(function(){settingCOME_BACK_NOTIFICATION_DURATIONArray.push($(this).text());});
        $('#tblsettinginfo .settingSIGNATURE_ORDER').each(function(){settingSIGNATURE_ORDERArray.push($(this).text());});
        $('#tblsettinginfo .settingSHOULD_FIND_SFS_SERVER').each(function(){settingSHOULD_FIND_SFS_SERVERArray.push($(this).text());});
        $('#tblsettinginfo .settingGAME_MAINTAIN').each(function(){settingGAME_MAINTAINArray.push($(this).text());});
        $('#tblsettinginfo .settingENABLE_LOG').each(function(){settingENABLE_LOGArray.push($(this).text());});
    $('#tblsettinginfo .settingENABLE_ADJUST_LOG').each(function(){settingENABLE_ADJUST_LOGArray.push($(this).text());});
        $('#tblsettinginfo .settingMAX_LOG').each(function(){settingMAX_LOGArray.push($(this).text());});
        $('#tblsettinginfo .settingENABLE_IAP_LOG').each(function(){settingENABLE_IAP_LOGArray.push($(this).text());});
        $('#tblsettinginfo .settingCHAT_INTERVAL').each(function(){settingCHAT_INTERVALArray.push($(this).text());});
        $('#tblsettinginfo .settingSEND_TROOP_SECONDS').each(function(){settingSEND_TROOP_SECONDSArray.push($(this).text());});
        $('#tblsettinginfo .settingSAVE_HISTORY_MINUTES').each(function(){settingSAVE_HISTORY_MINUTESArray.push($(this).text());});
        $('#tblsettinginfo .settingPING_INTERVAL_SECONDS').each(function(){settingPING_INTERVAL_SECONDSArray.push($(this).text());});
        $('#tblsettinginfo .settingREQUEST_TIME_OUT').each(function(){settingREQUEST_TIME_OUTArray.push($(this).text());});

        if (Sender.name === "editsettinginfo"){
          post_to_url("/lumba/gamedata/setting", { actionupdateinfo: "updatesettinginfo", settinfoSaveInterval: settingInfoSaveIntervalArray[0], settinfoIapRatio: settingInfoIapRatioArray[0], settinggemrangeforcalculatetime: settinggemrangeforcalculatetimeArray[0], settinggoldwaterrange: settinggoldwaterrangeArray[0], settingoilrange: settingoilrangeArray[0], settinggemrangeforcalculateresource: settinggemrangeforcalculateresourceArray[0], settingTERM_SERVICE_LINK_EN: settingTERM_SERVICE_LINK_EN_Array[0], settingTERM_SERVICE_LINK_AR: settingTERM_SERVICE_LINK_AR_Array[0], settingPOLICY_LINK_EN: settingPOLICY_LINK_EN_Array[0],settingPOLICY_LINK_AR: settingPOLICY_LINK_AR_Array[0], settingFACEBOOK_LINK: settingFACEBOOK_LINKArray[0], settingTWITTER_LINK: settingTWITTER_LINKArray[0], settingCOME_BACK_NOTIFICATION_DURATION: settingCOME_BACK_NOTIFICATION_DURATIONArray[0], settingSIGNATURE_ORDER: settingSIGNATURE_ORDERArray[0], settingSHOULD_FIND_SFS_SERVER: settingSHOULD_FIND_SFS_SERVERArray[0], settingSEND_TROOP_SECONDS: settingSEND_TROOP_SECONDSArray[0], settingSAVE_HISTORY_MINUTES: settingSAVE_HISTORY_MINUTESArray[0], settingGAME_MAINTAIN: settingGAME_MAINTAINArray[0], settingENABLE_LOG: settingENABLE_LOGArray[0], settingENABLE_ADJUST_LOG: settingENABLE_ADJUST_LOGArray[0], settingMAX_LOG: settingMAX_LOGArray[0], settingCHAT_INTERVAL: settingCHAT_INTERVALArray[0], settingENABLE_IAP_LOG: settingENABLE_IAP_LOGArray[0], settingPING_INTERVAL_SECONDS: settingPING_INTERVAL_SECONDSArray[0],settingREQUEST_TIME_OUT: settingREQUEST_TIME_OUTArray[0]})
        }
        return false;
}

function copyContentSettingSFS(x){
        var Sender = window.event.srcElement;
        var index = 0;
        var settingsfsIdArray = [];
        var settingsfsfromVersionArray = []; var settingsfstoVersionArray = []; var settingsfsupdateTypeArray = []; var settingsfsdescriptionArray = []; var settingsfsiosNewVersionUrlArray = [];
        var settingsfsandroidNewVersionUrlArray = [];

        $('#tblsettingsfs .sfsId').each(function(indexx, value){
        if ($(this).text() === x){ index = indexx;}
        });

        $('#tblsettingsfs .sfsfromVersion').each(function(){settingsfsfromVersionArray.push($(this).text());});
        $('#tblsettingsfs .sfstoVersion').each(function(){settingsfstoVersionArray.push($(this).text());});
        $('#tblsettingsfs .sfsupdateType').each(function(){settingsfsupdateTypeArray.push($(this).text());});
        $('#tblsettingsfs .sfsdescription').each(function(){settingsfsdescriptionArray.push($(this).text());});
        $('#tblsettingsfs .iosNewVersionUrl').each(function(){settingsfsiosNewVersionUrlArray.push($(this).text());});
        $('#tblsettingsfs .sfsandroidNewVersionUrl').each(function(){settingsfsandroidNewVersionUrlArray.push($(this).text());});

        if (Sender.name === "editsettingsfs"){
          post_to_url("/lumba/gamedata/setting", { actionupdatesfs: "updatesfs", id: x, settsfsfromVersion: settingsfsfromVersionArray[index], settsfstoVersion: settingsfstoVersionArray[index], settsfsupdateType: settingsfsupdateTypeArray[index], settsfsdescription: settingsfsdescriptionArray[index], settsfsiosNewVersionUrl: settingsfsiosNewVersionUrlArray[index], settsfsandroidNewVersionUrl: settingsfsandroidNewVersionUrlArray[index]})
        }
        return false;
}

function copyContentUserSendMail(x){
  var Sender = window.event.srcElement;
  var index = 0; var sendmail_usernameArray = []; var sendmail_emailArray = []; var sendmail_datepickerArray = [];
  $('#tblsendmail .emailIDCell').each(function(indexx, value){
    if ($(this).text() === x){ index = indexx;}
    });

    $('#tblsendmail .username').each(function(){sendmail_usernameArray.push($(this).text());});
    $('#tblsendmail .email').each(function(){sendmail_emailArray.push($(this).text());});
    if (Sender.name === "editusersendmail"){
          post_to_url("/lumba/sendemail", { actionupdate: "update", id: x, sendmail_username: sendmail_usernameArray[index], sendmail_email: sendmail_emailArray[index], sendemail_datepicker: $('#tblsendmail .datepicker').val()})
    }
    if(Sender.name === "deleteid"){
          post_to_url("/lumba/sendemail", {deleteid: x})
    }
}

function copyContentGameState(x){
        var Sender = window.event.srcElement;
        var index = 0;
        var settingArray = [];
        var gameItemArray = []; var objectKeyArray = []; var objectValueArray = [];
        var userId_inbox =  $("#userIdGameState").val();
        var userId = $('#tblGameItem .gamestate_userId').text();
        if (userId_inbox != userId) {
          alert("Diffirent userId");
          return false;
        }
        var gamestate_username = $('#tblGameItem .gamestate_userName').val();
        var gamestate_email = $('#tblGameItem .gamestate_email').val();
        var gamestate_password = $('#tblGameItem .gamestate_password').val();
        var gamestate_locale = $('#tblGameItem .gamestate_locale').val();
        var gamestate_facebookId = $('#tblGameItem .gamestate_facebookId').val();
        var gamestate_level = $('#tblGameItem .gamestate_Level').val();
        var gamestate_level_reason = $('#tblGameItem .gamestate_Level_Reason').val();
        var gamestate_exper = $('#tblGameItem .gamestate_ExPoints').val();
        var gamestate_points_reason = $('#tblGameItem .gamestate_Points_Reason').val();
        var gamestate_gold = $('#tblGameItem .gamestate_Gold').val();
        var gamestate_gold_reason = $('#tblGameItem .gamestate_Gold_Reason').val();
        var gamestate_water = $('#tblGameItem .gamestate_Water').val();
        var gamestate_water_reason = $('#tblGameItem .gamestate_Water_Reason').val();
        var gamestate_darkwater = $('#tblGameItem .gamestate_DarkWater').val();
        var gamestate_oil_reason = $('#tblGameItem .gamestate_Oil_Reason').val();
        var gamestate_gems = $('#tblGameItem .gamestate_Gems').val();
        var gamestate_pearls_reason = $('#tblGameItem .gamestate_Pearls_Reason').val();
        var gamestate_townhall = $('#tblGameItem .gamestate_TownHallLevel').val();
        var gamestate_diwanlevel_reason = $('#tblGameItem .gamestate_DiwanLevel_Reason').val();
        var gamestate_isFake = $('#tblGameItem .gamestate_isFake').val();
        var gamestate_trophies = $('#tblGameItem .gamestate_trophies').val();
        var gamestate_dagger_reason = $('#tblGameItem .gamestate_Dagger_Reason').val();
        var sfs_version = $("#sfs_version").val();

        /* setting*/
        $('#tblGameItemSetting .gamestate_setting').each(function(){settingArray.push($(this).text());}); // sound: settingArray[0], music: settingArray[1]
        var gamestate_sound = settingArray[0];
        var gamestate_music = settingArray[1];
        /* object key*/
        $('#tblGameStateObject .gamestate_object_key').each(function(){objectKeyArray.push($(this).text());});
        /*object value*/
        $('#tblGameStateObject .gamestate_object_value').each(function(){objectValueArray.push($(this).text());});
        if ((gamestate_level!="" && !$.isNumeric(gamestate_level)) || (!$.isNumeric(gamestate_exper) && gamestate_exper !="") || (!$.isNumeric(gamestate_gold) && gamestate_gold !="") || (!$.isNumeric(gamestate_water) && gamestate_water !="") || (!$.isNumeric(gamestate_darkwater) && gamestate_darkwater!="") || (!$.isNumeric(gamestate_gems)&&gamestate_gems!="") || (!$.isNumeric(gamestate_isFake)&&gamestate_isFake!="") || (!$.isNumeric(gamestate_trophies)&&gamestate_trophies!="")){
          alert("Wrong Format");
          return false;
        }
        for (var i=0;i<objectKeyArray.length; i++){
          if(objectKeyArray[i] === "nTiles"){
            objectKeyArray.splice(i,1);
            objectValueArray.splice(i,1);
            break;
          }
        }

        var object_str = "";
        for (var i = 0; i< objectKeyArray.length; i++){
          if(objectKeyArray[i] != "nTiles"){
            if (i != (objectKeyArray.length -1)){
            object_str = object_str + objectKeyArray[i] + "\"" + ":" + JSON.stringify(objectValueArray[i]) + ",\"";
            } else{
              object_str = object_str + "\"" + objectKeyArray[i] + "\"" + ":" + JSON.stringify(objectValueArray[i]);
            }
          }
        }
    post_to_url("/lumba/gamestate/user_details", { actionupdate: "update", sfs_version: sfs_version, userId: userId, gamestate_username: gamestate_username, gamestate_email: gamestate_email, gamestate_password: gamestate_password, gamestate_locale: gamestate_locale, gamestate_facebookId: gamestate_facebookId, gamestate_level: gamestate_level, gamestate_level_reason: gamestate_level_reason, gamestate_exper: gamestate_exper, gamestate_points_reason: gamestate_points_reason, gamestate_gold: gamestate_gold, gamestate_gold_reason: gamestate_gold_reason, gamestate_water: gamestate_water, gamestate_water_reason: gamestate_water_reason, gamestate_darkwater: gamestate_darkwater, gamestate_oil_reason: gamestate_oil_reason, gamestate_gems: gamestate_gems, gamestate_pearls_reason: gamestate_pearls_reason, gamestate_townhall: gamestate_townhall, gamestate_diwanlevel_reason: gamestate_diwanlevel_reason, gamestate_trophies: gamestate_trophies, gamestate_dagger_reason: gamestate_dagger_reason, gamestate_isFake: gamestate_isFake, gamestate_sound: gamestate_sound, gamestate_music: gamestate_music, object_str: 1 /*, objectKeyArray: objectKeyArray, objectValueArray: objectValueArray */})
        return false;
}

function copyContentJira(x){
    var Sender = window.event.srcElement;
    var index = 0;
    var settingArray = [];
    var gameItemArray = []; var objectKeyArray = []; var objectValueArray = [];
    var userId_inbox =  $("#userIdGameState").val();
    var userId = $('#tblGameItem .gamestate_userId').text();
    if (userId_inbox != userId) {
        alert("Diffirent userId");
        return false;
    }

    var sfs_version = $("#sfs_version").val();

    /* Create Jira */
    var jira_title = $('#tblGameItemJira .jtitle').val();
    var jira_description = $('#tblGameItemJira .jdescription').val();
    var jira_priority = $('#tblGameItemJira .jpriority').val();

    /* setting*/
    $('#tblGameItemSetting .gamestate_setting').each(function(){settingArray.push($(this).text());}); // sound: settingArray[0], music: settingArray[1]
    var gamestate_sound = settingArray[0];
    var gamestate_music = settingArray[1];
    /* object key*/
    $('#tblGameStateObject .gamestate_object_key').each(function(){objectKeyArray.push($(this).text());});
    /*object value*/
    $('#tblGameStateObject .gamestate_object_value').each(function(){objectValueArray.push($(this).text());});

    for (var i=0;i<objectKeyArray.length; i++){
        if(objectKeyArray[i] === "nTiles"){
            objectKeyArray.splice(i,1);
            objectValueArray.splice(i,1);
            break;
        }
    }

    var object_str = "";
    for (var i = 0; i< objectKeyArray.length; i++){
        if(objectKeyArray[i] != "nTiles"){
            if (i != (objectKeyArray.length -1)){
                object_str = object_str + objectKeyArray[i] + "\"" + ":" + JSON.stringify(objectValueArray[i]) + ",\"";
            } else{
                object_str = object_str + "\"" + objectKeyArray[i] + "\"" + ":" + JSON.stringify(objectValueArray[i]);
            }
        }
    }

    post_to_url("/lumba/gamestate/user_details", { actionupdateJira: "updateJira", jira_title: jira_title, jira_description: jira_description, jira_priority: jira_priority, sfs_version: sfs_version, userId: userId, gamestate_sound: gamestate_sound, gamestate_music: gamestate_music, object_str: 1 /*, objectKeyArray: objectKeyArray, objectValueArray: objectValueArray */})
    return false;
}

function copyBattlelog(x){
    var Sender = window.event.srcElement;
    var index = 0;
    var settingArray = [];
    var gameItemArray = []; var objectKeyArray = []; var objectValueArray = [];
    var userId_inbox =  $("#userIdGameState").val();
    var userId = $('#tblGameItem .gamestate_userId').text();
    if (userId_inbox != userId) {
        alert("Diffirent userId");
        return false;
    }

    var sfs_version = $("#sfs_version").val();

    /* Create Jira */
    var cpbl_destination_uid = $('#tblCopyBattleLog .cpbl_destination_uid').val();


    /* setting*/
    $('#tblGameItemSetting .gamestate_setting').each(function(){settingArray.push($(this).text());}); // sound: settingArray[0], music: settingArray[1]
    var gamestate_sound = settingArray[0];
    var gamestate_music = settingArray[1];
    /* object key*/
    $('#tblGameStateObject .gamestate_object_key').each(function(){objectKeyArray.push($(this).text());});
    /*object value*/
    $('#tblGameStateObject .gamestate_object_value').each(function(){objectValueArray.push($(this).text());});

    for (var i=0;i<objectKeyArray.length; i++){
        if(objectKeyArray[i] === "nTiles"){
            objectKeyArray.splice(i,1);
            objectValueArray.splice(i,1);
            break;
        }
    }

    var object_str = "";
    for (var i = 0; i< objectKeyArray.length; i++){
        if(objectKeyArray[i] != "nTiles"){
            if (i != (objectKeyArray.length -1)){
                object_str = object_str + objectKeyArray[i] + "\"" + ":" + JSON.stringify(objectValueArray[i]) + ",\"";
            } else{
                object_str = object_str + "\"" + objectKeyArray[i] + "\"" + ":" + JSON.stringify(objectValueArray[i]);
            }
        }
    }

    post_to_url("/lumba/gamestate/user_details", { actioncopyBattlelog: "copyBattlelog", cpbl_destination_uid: cpbl_destination_uid, sfs_version: sfs_version, userId: userId, gamestate_sound: gamestate_sound, gamestate_music: gamestate_music, object_str: 1 /*, objectKeyArray: objectKeyArray, objectValueArray: objectValueArray */})
    return false;
}

function copyReportUser(x){
    var Sender = window.event.srcElement;
    var index = 0;
    var settingArray = [];
    var gameItemArray = []; var objectKeyArray = []; var objectValueArray = [];
    var userId_inbox =  $("#userIdGameState").val();
    var userId = $('#tblGameItem .gamestate_userId').text();
    if (userId_inbox != userId) {
        alert("Diffirent userId");
        return false;
    }

    var sfs_version = $("#sfs_version").val();

    /* Report User */
    var reportuser_note = $('#tblReportUser .reportuser_note').val();
    var reportuser_user = $('#tblReportUser .reportuser_user').val();

    /* setting*/
    $('#tblGameItemSetting .gamestate_setting').each(function(){settingArray.push($(this).text());}); // sound: settingArray[0], music: settingArray[1]
    var gamestate_sound = settingArray[0];
    var gamestate_music = settingArray[1];
    /* object key*/
    $('#tblGameStateObject .gamestate_object_key').each(function(){objectKeyArray.push($(this).text());});
    /*object value*/
    $('#tblGameStateObject .gamestate_object_value').each(function(){objectValueArray.push($(this).text());});

    for (var i=0;i<objectKeyArray.length; i++){
        if(objectKeyArray[i] === "nTiles"){
            objectKeyArray.splice(i,1);
            objectValueArray.splice(i,1);
            break;
        }
    }

    var object_str = "";
    for (var i = 0; i< objectKeyArray.length; i++){
        if(objectKeyArray[i] != "nTiles"){
            if (i != (objectKeyArray.length -1)){
                object_str = object_str + objectKeyArray[i] + "\"" + ":" + JSON.stringify(objectValueArray[i]) + ",\"";
            } else{
                object_str = object_str + "\"" + objectKeyArray[i] + "\"" + ":" + JSON.stringify(objectValueArray[i]);
            }
        }
    }

    post_to_url("/lumba/gamestate/user_details", { actionReportUser: "copyReportUser", reportuser_note: reportuser_note, reportuser_user: reportuser_user, sfs_version: sfs_version, userId: userId, gamestate_sound: gamestate_sound, gamestate_music: gamestate_music, object_str: 1 /*, objectKeyArray: objectKeyArray, objectValueArray: objectValueArray */})
    return false;
}

function copyContentNewGame(x){
        var Sender = window.event.srcElement;
        var index = 0;
        var settingArray = [];
        var gameItemArray = []; var objectKeyArray = []; var objectValueArray = [];
        var gamestate_level = $('#tblnewGameItem .gamestate_Level').text();
        var gamestate_exper = $('#tblnewGameItem .gamestate_ExPoints').text();
        var gamestate_gold = $('#tblnewGameItem .gamestate_Gold').text();
        var gamestate_water = $('#tblnewGameItem .gamestate_Water').text();
        var gamestate_darkwater = $('#tblnewGameItem .gamestate_DarkWater').text();
        var gamestate_gems = $('#tblnewGameItem .gamestate_Gems').text();
        var gamestate_townhall = $('#tblnewGameItem .gamestate_TownHallLevel').text();
        var gamestate_trophies = $('#tblnewGameItem .gamestate_trophies').text();
        /* setting*/
        $('#tblnewGameItemSetting .gamestate_setting').each(function(){settingArray.push($(this).text());}); // sound: settingArray[0], music: settingArray[1]
        var gamestate_sound = settingArray[0];
        var gamestate_music = settingArray[1];

        /* object key*/
        $('#tblnewGame .gamestate_object_key').each(function(){objectKeyArray.push($(this).text());});
        /*object value*/
        $('#tblnewGame .gamestate_object_value').each(function(){objectValueArray.push($(this).text());});

        for (var i=0;i<objectKeyArray.length; i++){
          if(objectKeyArray[i] === "nTiles"){
            objectKeyArray.splice(i,1);
            objectValueArray.splice(i,1);
            break;
          }
        }

        var object_str = "";
        for (var i = 0; i< objectKeyArray.length; i++){
          if(objectKeyArray[i] != "nTiles"){
            if (i != (objectKeyArray.length -1)){
            object_str = object_str + objectKeyArray[i] + "\"" + ":" + JSON.stringify(objectValueArray[i]) + ",\"";
            } else{
              object_str = object_str + "\"" + objectKeyArray[i] + "\"" + ":" + JSON.stringify(objectValueArray[i]);
            }
          }
        }
        post_to_url("/lumba/gamedata/newgame", { actionupdate: "update", object_str: 1, objectKeyArray: objectKeyArray, objectValueArray: objectValueArray, gamestate_level: gamestate_level, gamestate_exper: gamestate_exper, gamestate_gold: gamestate_gold, gamestate_water: gamestate_water, gamestate_darkwater: gamestate_darkwater, gamestate_gems: gamestate_gems, gamestate_townhall: gamestate_townhall, gamestate_trophies: gamestate_trophies, gamestate_sound: gamestate_sound, gamestate_music: gamestate_music})
        return false;
}

function createNewGame(x) {
  bush_num = parseInt($('#bush_number').val(),10);//$('#bush_number').val();
  deadpalm_num = parseInt($('#deadpalm_number').val(),10);//$('#deadpalm_number').val();
  minypalm_num = parseInt($('#minipalmtree_number').val(), 10);
  palmtreegroup_num = parseInt($('#palmtreegroup_number').val(), 10);
  xsmallrock_num = parseInt($('#xsmallrock_number').val(), 10);
  crackedrock_num = parseInt($('#crackedrock_number').val(), 10);
  largerock_num = parseInt($('#largerock_number').val(), 10);
  tree_num = parseInt($('#tree_number').val(), 10);
  camelskeleton_num = parseInt($('#camelskeleton_number').val(), 10);
  palmtree_num = parseInt($('#palmtree_number').val(), 10);
  smallrock_num = parseInt($('#smallrock_number').val(), 10);
  tinyrock_num = parseInt($('#tinyrock_number').val(), 10);
  mediumrock_num = parseInt($('#mediumrock_number').val(), 10);
  if ((bush_num + deadpalm_num + minypalm_num + palmtreegroup_num + xsmallrock_num + crackedrock_num + largerock_num + tree_num + camelskeleton_num + palmtree_num + smallrock_num + tinyrock_num + mediumrock_num) > 49){
    alert("total element have to <= 49");
    return false;
  } else {
    post_to_url("/lumba/gamedata/newgame", { actionnew: "new", bush_num: bush_num, deadpalm_num: deadpalm_num, minypalm_num: minypalm_num, palmtreegroup_num: palmtreegroup_num, xsmallrock_num: xsmallrock_num, crackedrock_num: crackedrock_num, largerock_num: largerock_num, tree_num: tree_num, camelskeleton_num: camelskeleton_num, palmtree_num: palmtree_num, smallrock_num: smallrock_num, tinyrock_num: tinyrock_num, mediumrock_num: mediumrock_num})
  }
}
