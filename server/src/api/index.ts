import express, { Application, Router } from "express"
import { fail2ban } from "../"

import Account from "./account"
import Schedule from './schedule'

class API {
    constructor() {
        const app: Application = express()

        app.use((req, res, next) => {
            if (process.env.PANIC) {
                res.send(500).json({
                    success: false,
                    code: "PANIC"
                })
                return
            }
            next()
        })
        if (process.argv.indexOf('--v') !== -1) app.use(require('morgan')('combined'))
        if (process.argv.indexOf('--no-fail2ban') === -1) app.use(fail2ban.middleware)

        app.use('/account', new Account().router)
        app.use('/schedule', new Schedule().router)

        app.use((err: any, req: any, res: any, next: any) => {
            console.log(err)
            res.status(500).send({success: false, cache: false, code: "remote.error", status: err?.response?.status, text: err?.response?.statusText})
        })

        app.listen(parseInt(process.env.PORT!), ()=>console.log(`🔥 HTTP server running and listening on port ${process.env.PORT!}.`))
    }
}

export default API
