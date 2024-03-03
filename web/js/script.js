const app = new Vue({
    el: '#app',

    data: {
        nomeRisorsa : GetParentResourceName(),

        canUserOpenStaffStats : false,

        serverLogo : "https://cdn.discordapp.com/attachments/944572269202640946/1023536303180107856/tech2.png?ex=65e44bf7&is=65d1d6f7&hm=ced1dbe69cd051c1ae15bed82a641532b19b9941a9403de462224aa0613ae0ce&",

        staffAction : [
            {
                icon : "home",
                locales : "dashboard"
            },
            {
                icon : "flag",
                locales : "report_list"
            },
            {
                icon : "user",
                locales : "report_claimed"
            },
            {
                icon : "shield",
                locales : "staff_list"
            }
        ],

        userAction : [
            {
                icon : "create",
                locales : "create_new_report"
            },
            {
                icon : "flag",
                locales : "report_list"
            },
            {
                icon : "shield",
                locales : "staff_list"
            }
        ],

        selectedOption : 0,

        locales : {},

        myInfo : {
            id : null,
        },

        staff : [
            // {
            //     name : "R1CKY",
            //     identifier : "char1:asd",
            //     id : 1,
            //     available : false
            // },
            // {
            //     name : "Loris",
            //     identifier : "char1:loris",
            //     id : 2,
            //     available : true
            // }
        ],

        report : [
            {
                id : 1,
                userInfo : {
                    identifier : "char1:asd",
                    name : "R1CKY",
                    discord : '638415863682170881',
                    license : false,
                    steam : false,
                    // avatar : "https://cdn.discordapp.com/attachments/944572269202640946/1008064551494881310/logoricky.png?ex=65d0ecc6&is=65be77c6&hm=c22ebe09a2413cd7f444d66ff1e5c8f7e2f867118f619e842940e7eb3b59412d&"
                },
                title : "VFM",
                type : 'question',
                staff : ['char1:loris'],
                claimed : true,
                messages : [
                    {
                        fromIdentifier : "char1:asd",
                        staff : true,
                        name : "R1CKY",
                        type : 'message', // message, image, position
                        content : "Msg Staff Content"
                    },
                    {
                        fromIdentifier : "char1:loris",
                        staff : true,
                        name : "Loris",
                        type : 'message', // message, image, position
                        content : "Other Msg Staff Content"
                    },
                    {
                        fromIdentifier : "char1:loris",
                        staff : false,
                        name : "NOME",
                        type : 'message', // message, image, position
                        content : "Msg User Content"
                    }
                ]
            }
        ],

        staffChat : [
            // {
            //     fromIdentifier : "char1:asd",
            //     name : "R1CKY",
            //     type : 'message', // message, image, position
            //     content : "Hello asdasd asd asd s asdsa dsa dsadsssssssssssssss sssas asdsa da d asdad a  asdsad sad"
            // },
            // {
            //     fromIdentifier : "char1:altropg",
            //     name : "Loris",
            //     type : 'message', // message, image, position
            //     content : "Hello 2"
            // }
        ],


        reportName : '', // Report search name
        staffName : '',
        reportSelected : {}, // Report selected
        reportActionSelected : 0, // 0 = User INFO, 1 = Chat, 2 = Actions

        staffInfo : {},

        newReportSettings : {
            title : '',
            type : 'player', // player, bug, question
        },

        screenActive : '',
        screenActive2 : '',

        checkIdentifierOnline : '', // Identifier to check if is online


        statistic : {
            ['report_claimed'] : 0,
            ['report_closed'] : 0,
            ['sent_messages'] : 0  
        },

        viewImage : {
            enable : false,
            url : ''
        },
        returnPlayerStaff : false,
    },

    methods: {
        postNUI(type, data) {
            return $.post(`https://${this.nomeRisorsa}/${type}`, JSON.stringify(data))
        },

        playerStaff() {
            return this.returnPlayerStaff
        },

        async changeActivePage(index) {
            if(index == 'staff_list') {
                this.staff = await this.postNUI('getStaff')
            }
            this.screenActive = index
            this.screenActive2 = ''
        },

        async changeActivePage2(index) {
            var wait = false
            if(index == 'staff_chat') {
                this.staffChat = await this.postNUI('getStaffChat')
                setTimeout(() => {
                    var objDiv = document.getElementById("chatStaff");
                    objDiv.scrollTop = objDiv.scrollHeight;
                }, 0);
            } else if(index == 'statistics' || index == 'staff_info') {
                wait = true
                this.screenActive2 = 'loading_information'
                await this.getStatistic('report_claimed')
                await this.getStatistic('report_closed')
                await this.getStatistic('sent_messages')
            } else {
                this.postNUI('noStaffChat')
            }
            if(wait) {
                setTimeout(() => {
                    this.screenActive2 = index
                }, 1500);
            } else {
                this.screenActive2 = index
            }
        },

        latestReport() {
            var reports = []
            var reportss = this.report.slice().reverse()

            for(var i = reportss.length - 1; i >= 0; i--) {
                if(reports.length == 2) {
                    break
                }
                if(!reportss[i].closed) {
                    reports.push(reportss[i])
                }
            }
            return reports
        },
        
        getMyInfo(type, identifier) {
            return this.myInfo[type]
        },

        staffAvailable() {
            var staff = []
            for(var i = 0; i < this.staff.length; i++) {
                if(this.staff[i].available) {
                    staff.push(this.staff[i])
                }
            }
            return staff
        },

        changeAvailable() {
            this.playSound('menu')
            this.myInfo.available = !this.myInfo.available
            this.postNUI('changeAvailable', {
                identifier : this.myInfo.identifier,
                available : this.myInfo.available,
                name : this.myInfo.name,
                id : this.myInfo.id
            })
        },


        async getStatistic(type, identifier) {
            if(!identifier) {
                identifier = this.getMyInfo('identifier')
            }

            var statistica = await this.postNUI('getStatistic', {
                type : type,
                identifier : identifier
            })
            this.statistic[type] = statistica
        },

        sendMessageToChatStaff(type) {
            var content = document.getElementById('staffMessage').value
            if(type == 'message') {
                if(content.length > 0) {
                    this.postNUI('sendMessageToChatStaff', {
                        name : this.getMyInfo('name'),
                        type : type,
                        content : content
                    })
                }
            } else if(type == 'position') {
                this.postNUI('sendMessageToChatStaff', {
                    name : this.getMyInfo('name'),
                    type : type
                })
            } else if(type == 'image') {
                this.postNUI('send_image')
                $("#containerReport").fadeOut(500);
                this.changeActivePage('send_image')
            }
            document.getElementById('staffMessage').value = ""
            setTimeout(() => {
                var objDiv = document.getElementById("chatStaff");
                objDiv.scrollTop = objDiv.scrollHeight;
            }, 0);
            this.playSound('menu')
        },


        setWaypoint(position) {
            this.postNUI('setWaypoint', {
                position : position
            })
            this.closeNui()
        },

        filterReport(onlyClaimed) {
            if(!onlyClaimed) {
                if(this.playerStaff()) {
                    if(this.reportName.length > 0) {
                        var reports = []
                        for(var i = 0; i < this.report.length; i++) {
                            if(this.report[i].title.toLowerCase().includes(this.reportName.toLowerCase())) {
                                if(!this.report[i].closed) {
                                    reports.push(this.report[i])
                                }
                            }
                        }
                    } else {
                        var reports = []
                        for(var i = 0; i < this.report.length; i++) {
                            if(!this.report[i].closed) {
                                reports.push(this.report[i])
                            }
                        }
                    
                    }
                } else {
                    if(this.reportName.length > 0) {
                        var reports = []
                        for(var i = 0; i < this.report.length; i++) {
                            if(this.report[i].title.toLowerCase().includes(this.reportName.toLowerCase())) {
                                reports.push(this.report[i])
                            }
                        }
                        return reports
                    } else {
                        var reports = []
                        for(var i = 0; i < this.report.length; i++) {
                            reports.push(this.report[i])
                        }
                        return reports
                    }
                }
            } else {
                var reports = []
                if(this.reportName.length > 0) {
                    for(var i = 0; i < this.report.length; i++) {
                        if(this.report[i].title.toLowerCase().includes(this.reportName.toLowerCase())) {
                            if(this.report[i].staff) {
                                for(var j = 0; j < this.report[i].staff.length; j++) {
                                    if(this.report[i].staff[j] == this.getMyInfo('identifier')) {
                                        reports.push(this.report[i])
                                    }
                                }
                            }
                        }
                    }
                    return reports
                } else {
                    for(var i = 0; i < this.report.length; i++) {
                        if(this.report[i].staff) {
                            for(var j = 0; j < this.report[i].staff.length; j++) {
                                if(this.report[i].staff[j] == this.getMyInfo('identifier')) {
                                    reports.push(this.report[i])
                                }
                            }
                        }
                    }
                    return reports
                }
            }
        },

        async openReport(idReport) {
            this.postNUI('selectReport', {
                idReport : idReport
            })
            if(this.screenActive == 'dashboard' || this.screenActive == 'create_new_report' || this.screenActive == 'report_claimed') {
                this.screenActive = 'report_list'
                for(var i = 0; i < this.report.length; i++) {
                    if(this.report[i].id == idReport) {
                        this.reportSelected = this.report[i]
                    }
                }
                this.changeActivePage2('report_info')
            }
            this.playSound('menu')
            for(var i = 0; i < this.report.length; i++) {
                if(this.report[i].id == idReport) {
                    this.reportSelected = this.report[i]
                }
            }
            this.screenActive2 = 'loading_information'
            this.getIdentifierOnline(this.reportSelected.userInfo.frameworkIdentifier)
            var avatar = await this.postNUI('getAvatar', {
                idDiscord : this.reportSelected.userInfo.discord
            })
            this.reportSelected.userInfo.avatar = avatar
            this.reportActionSelected = 1
            setTimeout(() => {
                this.changeActivePage2('report_chat')
                setTimeout(() => {
                    var objDiv = document.getElementById("chatReport");
                    objDiv.scrollTop = objDiv.scrollHeight;
                }, 0);
            }, 2000);
        },

        getReportsOfUser(identifier) {
            var searchText = this.reportName
            var reports = []
            for(var i = 0; i < this.report.length; i++) {
                if(this.report[i].userInfo.identifier == identifier) {
                    if(searchText.length > 0) {
                        if(this.report[i].title.toLowerCase().includes(searchText.toLowerCase())) {
                            reports.push(this.report[i])
                        }
                    } else {
                        reports.push(this.report[i])
                    }
                }
            }
            return reports
        },
        
        async changeReportActionSelected(index) {
            this.reportActionSelected = index
            switch(index) {
                case 0:
                    this.changeActivePage2('user_info')
                    break;
                case 1:
                    this.changeActivePage2('report_chat')
                    break;
                case 2:
                    this.changeActivePage2('report_actions')
                    break;
                default:
                    this.changeActivePage2('report_info')
                    break;
            }
        },

        sendMessageToReport(type) {
            const idReport = this.reportSelected.id
            var content = document.getElementById('message').value
            if(type == 'message') {
                if(content.length > 0) {
                    // NUI Callback to send message to report

                    this.postNUI('sendMessageToReport', {
                        idReport : idReport,
                        type : type,
                        content : content
                    })
                }
            } else if(type == 'position') {
                this.postNUI('sendMessageToReport', {
                    idReport : idReport,
                    type : type
                })
            } else if(type == 'image') {
                this.postNUI('send_image')
                $("#containerReport").fadeOut(500);
                this.changeActivePage('send_image')
            }
            $('#message').val('')
        },


        async getIdentifierOnline(identifier) {
            var online = await this.postNUI('getIdentifierOnline', {
                identifier : identifier
            })
            this.checkIdentifierOnline = online
        },

        copyLicense(license) {
            if(license) {
                var copyText = this.reportSelected.userInfo[license]
                var textArea = document.createElement("textarea")
                textArea.value = copyText
                document.body.appendChild(textArea)
                textArea.select()
                document.execCommand("Copy")
                textArea.remove()
                document.getElementById(license).style.height = "0.615vw"
                document.getElementById(license).style.width = "0.911vw"
                document.getElementById(license).src = "./img/copied.png"
                setTimeout(() => {
                    document.getElementById(license).style.height = "1.042vw"
                    document.getElementById(license).style.width = "0.938vw"
                    document.getElementById(license).src = "./img/copy.png"
                }, 2000);
            }
            this.playSound('menu')
        },

        saveAnnotation(identifier, event) {
            const newText = event.target.value
            this.postNUI('saveAnnotation', {
                identifier : identifier,
                annotation : newText
            })
        },


        viewUserReports() {
            this.playSound('menu')
            this.reportActionSelected = 4
        },

        claimedReport() {
            var staffs = this.reportSelected.staff
            for(var i = 0; i < staffs.length; i++) {
                if(staffs[i] == this.getMyInfo('identifier')) {
                    return true
                }
            }
            return false
        },

        action(type) {
            if(type == 'closeReport') {
                if(this.reportSelected.closed) {
                    return
                }
            }
            this.postNUI('action', {
                type : type,
                identifier : this.reportSelected.userInfo.frameworkIdentifier,
                myIdentifier : this.getMyInfo('identifier'),
                idReport : this.reportSelected.id,
                claimed : this.claimedReport()
            })
            this.playSound('menu')
        },

        playSound(fileName) {
            var audio = new Audio('./sound/' + fileName + '.mp3');
            audio.play();
        },

        staffList() {
            var searchText = this.staffName
            var staff = []
            if(searchText.length > 0) {
                for(var i = 0; i < this.staff.length; i++) {
                    if(this.staff[i].name.toLowerCase().includes(searchText.toLowerCase())) {
                        staff.push(this.staff[i])
                    }
                }
            } else {
                staff = this.staff
            }
            return staff
        },

        openStaffInfo(identifier) {
            if(this.canUserOpenStaffStats) {
                this.playSound('menu')
                for(var i = 0; i < this.staff.length; i++) {
                    if(this.staff[i].identifier == identifier) {
                        this.staffInfo = this.staff[i]
                    }
                }
                this.changeActivePage2('staff_info')
            }
        },

        changeNewReportSettings(val, key) {
            this.newReportSettings[val] = key
        },

        createNewReport() {
            var type = this.newReportSettings.type
            var title = this.newReportSettings.title
            if(!type || !title) {
                return
            }

            this.postNUI('createNewReport', {
                type : type,
                title : title
            })
        },

        closeNui() {
            this.playSound('menu')
            $("#app").fadeOut(500)
            this.postNUI('close', {})
        },

        viewFullImage(url, disable) {
            if(disable) {
                this.viewImage.enable = false
                this.viewImage.url = ''
                return
            }
            this.viewImage.enable = true
            this.viewImage.url = url
        }
    }

});

document.onkeyup = function (data) {
    if (data.key == 'Enter') {
        switch(app.screenActive2) {
            case 'staff_chat':
                app.sendMessageToChatStaff('message')
                break;
            case 'report_chat':
                if(app.reportActionSelected == 1) {
                    app.sendMessageToReport('message')
                }
                break;
        }
    } else if(data.key == 'Escape') {
        var selectedOne = false
        switch(app.screenActive2) {
            case 'staff_chat':
                selectedOne = true
                app.changeActivePage2('')
                break;
            case 'report_chat':
                selectedOne = true
                app.changeActivePage('report_list')
                app.changeActivePage2('')
                break;
            case 'report_list':
                selectedOne = true
                app.changeActivePage('dashboard')
                break;
            case 'staff_info':
                selectedOne = true
                app.changeActivePage2('')
                break;
            case 'statistics':
                selectedOne = true
                app.changeActivePage2('')
                break;
            case 'user_info':
                selectedOne = true
                if(app.reportActionSelected == 4) {
                    app.reportActionSelected = 0
                } else {
                    app.changeActivePage2('')
                }
                break;
            case 'report_actions':
                selectedOne = true
                app.changeActivePage2('')
                break;
        }

        if(selectedOne) {
            return
        }

        switch(app.screenActive) {
            case 'report_list':
                app.closeNui()
                break;
            case 'create_new_report':
                app.closeNui()
                break;
            case 'dashboard':
                app.closeNui()
                break;
            case 'staff_list':
                app.closeNui()
                break;
        }
    }
};

window.addEventListener('message', async function(event) {
    var data = event.data;
    if (data.type === "OPEN_STAFF") {
        app.changeActivePage('dashboard')
        app.changeActivePage2('')
        app.returnPlayerStaff = true;

        data.reports = data.reports.slice().reverse()
        app.report = data.reports
        $("#app").fadeIn(500)
    } else if (data.type === "OPEN_USER") {
        app.changeActivePage('create_new_report')
        app.changeActivePage2('')
        app.returnPlayerStaff = false;
        data.reports = data.reports.slice().reverse()
        app.report = data.reports
        $("#app").fadeIn(500)
    } else if(data.type === "SET_MY_INFO") {
        app.myInfo.id = data.id
        app.myInfo.identifier = data.identifier
        app.myInfo.name = data.name
    } else if(data.type === "UPDATE_REPORT") {
        data.reports = data.reports.slice().reverse()
        app.report = data.reports
        if(app.reportSelected.id) {
            for(var i = 0; i < app.report.length; i++) {
                if(app.report[i].id == app.reportSelected.id) {
                    var lastAvatar = app.reportSelected.userInfo.avatar
                    app.reportSelected = app.report[i]
                    app.reportSelected.userInfo.avatar = lastAvatar
                    if(app.reportActionSelected == 1) {
                        setTimeout(() => {
                            var objDiv = document.getElementById("chatReport");
                            objDiv.scrollTop = objDiv.scrollHeight;
                        }, 0);
                    }
                }
            }
        }
    } else if(data.type === "OPEN_REPORT") {
        const idReport = data.id 
        app.openReport(idReport)
    } else if(data.type === "UPDATE_STAFF") {
        app.staff = data.staff
    } else if(data.type === "UPDATE_STAFF_CHAT") {
        app.staffChat = data.messages
        if(app.screenActive2 == 'staff_chat') {
            setTimeout(() => {
                var objDiv = document.getElementById("chatStaff");
                objDiv.scrollTop = objDiv.scrollHeight;
            }, 0);
        }
    } else if(data.type === "SET_CONFIGVALUE") {
        app.locales = data.locales
        app.serverLogo = data.url
        app.canUserOpenStaffStats = data.canUserOpenStaffStats
    } else if(data.type === 'SHOW_CONTAINER') {
        $("#containerReport").fadeIn(500);
        if(data.openReport) {
            app.screenActive = 'report_list'
            app.screenActive2 = 'report_chat'
        } else {
            app.screenActive = 'dashboard'
            app.screenActive2 = 'staff_chat'
        }
    }
})

