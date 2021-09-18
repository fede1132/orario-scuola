import nodemailer from "nodemailer"

class Mail {
    private mailer = nodemailer.createTransport({
        pool: true,
        host: process.env.MAIL_HOST!,
        port: 587,
        secure: false,
        requireTLS: true,
        auth: {
            user: process.env.MAIL_USER,
            pass: process.env.MAIL_PASS
        },
        connectionTimeout: 5000
    })
    constructor() {
        this.mailer.verify((error, success) => {
            if (error) {
                console.log(`❌ Got an error while trying to verify nodemailer! Error:\n${error}`)
                return
            }
            console.log("🔥 Mail system is running.")
        })
    }

    async sendCode(email: string, code: number): Promise<void> {
        let message = {
            from: process.env.MAIL_MAIL,
            sender: `${process.env.MAIL_FROM} <${process.env.MAIL_MAIL}>`,
            to: email,
            subject: 'Orario Scuola - Codice di autenticazione',
            text: `Il tuo codice di accesso per Orario Scuola è ${code}. Questo è un messaggio automatico e questa è una casella email di solo invio, pertanto se cerchi aiuto tramite questa casella, nessuno ti rispoderà!`,
            html: `Il tuo codice di accesso per Orario Scuola è <b>${code}</b>. Questo è un messaggio automatico e questa è una casella email di solo invio, pertanto se cerchi aiuto tramite questa casella, nessuno ti rispoderà!`
        }
        await this.mailer.sendMail(message)
    }
}

export default Mail
