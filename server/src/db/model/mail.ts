class Mail {
    email: string | undefined
    time: number | undefined

    constructor(email: string | undefined = undefined, time: number | undefined = undefined) {
        this.email = email
        this.time = time
    }
}

export default Mail
