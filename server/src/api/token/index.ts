import { Router } from "express"
import { db, mail } from "../../"

class Token {
    router: Router = Router()
    constructor() {

        this.router.post('/getToken', async (req, res) => {
            let email: string | undefined = <string | undefined>req.query.email
            let code: string | undefined = <string | undefined>req.query.code
            if (code === undefined) {
                res.status(400).send({success: false, code: "code.invalid"})
                return
            }
            if (email === undefined || !email.endsWith('@gobettire.istruzioneer.it')) {
                res.status(400).send({success: false, code: "email.invalid"})
                return
            }
            let mailCode = db.getMailCode(email!)
            if (mailCode === undefined) {
                res.status(400).send({success: false, code: "email.not-exists"})
                return
            }
            console.log(mailCode)
            if (mailCode !== parseInt(code)) {
                res.status(400).send({success: false, code: "code.invalid"})
                return
            }
            let token: any = db.getToken(email!, true)
            res.status(200).send({success: true, code: "token.received", token: token.token})
        })

    }
}

export default Token
