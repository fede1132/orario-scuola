var chars = "abcdefghijklmnopqrstuvwyz"
chars += chars.toUpperCase()
chars += "0123456789!;<>-$*"

export function genToken(): string {
    let token = "";
    for (let i=0;i<=parseInt(process.env.TOKEN_LENGTH!);i++) {
        token += chars[getRandomInt(0, chars.length)]
    }
    return token
}

export function genCode(): number {
    let code = ""
    for (let i=0;i<=parseInt(process.env.CODE_LENGTH!);i++) {
        code += `${getRandomInt(0, 9)}`
    }
    return parseInt(code)
}

function getRandomInt(min: number, max: number) {
    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(Math.random() * (max - min + 1)) + min;
}
