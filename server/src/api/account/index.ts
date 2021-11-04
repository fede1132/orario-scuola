import { Router } from "express"
import { db, fail2ban, mail } from "../../"
import { genCode } from "../../util/generator"

class Account {
    router: Router = Router()
    constructor() {

        this.router.post('/login', async (req, res) => {
            let email: string | undefined = <string | undefined>req.query.email?.toString()?.toLowerCase()
            let code: string | undefined = <string | undefined>req.query.code
            if (code === undefined) {
                if ((await fail2ban.isMailBanned(email!))) {
                    res.status(403).send({success: false, code: "banned.email"})
                    return
                }
                let code = genCode()
                await mail.sendCode(email!, code)
                db.newMail(email!, code)
                res.status(200).send({success:true, code: "token.check-mail"})
                return
            }
            if (email === undefined || !email.endsWith('@gobettire.istruzioneer.it')) {
                res.status(400).send({success: false, code: "email.invalid"})
                return
            }
            let mailCode = db.getMailCode(email!)
            if (mailCode === undefined) {
                res.status(400).send({success: false, code: "code.invalid"})
                return
            }
            if (mailCode !== parseInt(code)) {
                res.status(400).send({success: false, code: "code.invalid"})
                return
            }
            let token: any = db.getToken(email!, true)
            res.status(200).send({success: true, code: "token.received", token: token.token})
        })

    }
}

export default Account
