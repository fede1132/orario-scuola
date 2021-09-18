import express, { Application, Router } from "express"
import { fail2ban } from "../"

import Mail from './mail'
import Schedule from './schedule'
import Token from './token'

class API {
    constructor() {
        const app: Application = express()

        if (process.argv.indexOf('--v') !== -1) app.use(require('morgan')('combined'))
        if (process.argv.indexOf('--no-fail2ban') === -1) app.use(fail2ban.middleware)

        app.use('/mail', new Mail().router)
        app.use('/schedule', new Schedule().router)
        app.use('/token', new Token().router)

        app.listen(parseInt(process.env.PORT!), ()=>console.log(`🔥 HTTP server running and listening on port ${process.env.PORT!}.`))
    }
}

export default API
