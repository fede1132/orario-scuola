import { Router } from "express"
import { db } from "../.."
import auth from "../../auth"


class Schedule {
    router: Router = Router()

    constructor() {

        this.router.get('/updateSchedule', async (req, res) => {
            let url: string | undefined = <string | undefined>req.query.url
            let token: string | undefined = <string | undefined>req.query.token
            if (url===undefined) {
                res.status(400).send({success:false, code:"url.not-present"})
                return
            }
            if (token === undefined) {
                res.status(400).send({success:false, code:"token.invalid"})
                return
            }
            if (!db.isAdmin(token)) {
                res.status(403).send({success:false, code:"token.not-admin"})
                return
            }
            db.updateScheduleUrl(url)
            res.status(200).send({success: true, code:"schedule.updated"})
        })

        this.router.get('/getSchedule', auth, async (req, res) => {
            res.send(`${db.isAdmin(req.query.token?.toString()!)}`)
        })

    }

}

export default Schedule
