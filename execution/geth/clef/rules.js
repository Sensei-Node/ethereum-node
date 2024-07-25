function OnSignerStartup(info) { }

function ApproveListing() {
    return 'Approve';
}

function ApproveSignData(r) {
    if (r.content_type == "application/x-clique-header") {
        for (var i = 0; i < r.messages.length; i++) {
            var msg = r.messages[i]
            if (msg.name == "Clique header" && msg.type == "clique") {
                return "Approve"
            }
        }
    }
    return "Reject"
}