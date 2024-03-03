Config = {}

Config.Framework = 'autodetect' -- esx, qbcore, autodetect

Config.ServerLogo = 'https://cdn.discordapp.com/attachments/944572269202640946/1023536303180107856/tech2.png?ex=65e44bf7&is=65d1d6f7&hm=ced1dbe69cd051c1ae15bed82a641532b19b9941a9403de462224aa0613ae0ce&'

Config.LicenseType  = 'license' -- steam, discord or license

Config.CanUserOpenStaffStats = true

Config.StaffGroups = {
    'admin',
    'god'
}

Config.KeyMapping = {
    sendImage = {
        key = 'E',
        description = "Send Photo"
    },
    sendImage2 = {
        key = 'BACK',
        description = "Return Back"
    },
    openReport = {
        enable = true,
        key = 'F7',
        description = "Open Report Menu"
    },
    openReportStaff = {
        enable = true,
        key = 'H',
        description = "Open Staff Report Menu"
    },
}

Config.Command = {
    openReport = {
        commandName = 'report',
    },
    openReportStaff = {
        commandName = 'reportstaff',
    }
}

Config.Locales = {
    ['create_new_report'] = "Create New Report",
    ['actions'] = "Actions",
    ['close'] = "Close",
    ['dashboard'] = "Dashboard",
    ['report_list'] = "Report List",
    ['report_claimed'] = "Report Claimed",
    ['staff_list'] = "Staff List",
    ['welcome_back'] = "Welcome back",
    ['you_are_available'] = "You are available",
    ['you_are_not_available'] = "You are not available",
    ['latest'] = "Latest",
    ['report'] = "Report",
    ['staff'] = "Staff",
    ['available'] = "Available",
    ['your'] = "Your",
    ['statistics'] = "Statistics",
    ['open'] = "Open",
    ['chat'] = "Chat",
    ['report_closed'] = "Report Closed",
    ['sent_messages'] = "Sent Messages",
    ['staff_chat'] = "Staff Chat",
    ['type_something'] = "Type something",
    ['set_pos'] = "Click to set position",
    ['search_from_title'] = "Search from title",
    ['user_info'] = "User Info",
    ['chat'] = "Chat",
    ['actions'] = "Actions",
    ['license'] = "License",
    ['steam'] = "Steam",
    ['discord'] = "Discord",
    ['not_found'] = "Not found",
    ['view'] = "View",
    ['all_reports'] = "All Reports",
    ['set'] = "Set",
    ['annotation'] = "Annotation",
    ['add_note'] = "Add a note",
    ['current'] = "Current",
    ['report_actions'] = "Report Actions",
    ['user_actions'] = "User Actions",
    ['claim'] = "Claim",
    ['claimed'] = "Claimed",
    ['goto'] = "Go to",
    ['bring'] = "Bring",
    ['freeze'] = "Freeze",
    ['search_from_name'] = "Search from name",
    ['player'] = "Player",
    ['bug'] = "Bug",
    ['question'] = "Question",
    ['title'] = "Title",
    ['create'] = "Create",
    ['loading_information'] = "Loading Information...",
    ['send_photo'] = "[E] Send Photo",
    ['return_back'] = "[Backspace] Return Back",
    ['closed'] = "Closed",
    ['report_closed2'] = "Report Closed",
}

Config.Notification = {
    ['new_report'] = {
        label = "New Report!",
        type = "info"
    },
    ['new_message'] = {
        label = "New Message!",
        type = "info"
    },
    ['new_waypoint'] = {
        label = "The waypoint has been set",
        type = "info"
    },
    ['your_report_claimed'] = {
        label = "Your report has been claimed",
        type = "info"
    }
}

Config.NotificationFunction = function(message, type)
    if Framework == 'esx' then 
        ESX.ShowNotification(message, type)
    elseif Framework == 'qbcore' then
        QBCore.Functions.Notify(message, type)
    end
end