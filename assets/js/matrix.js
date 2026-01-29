const canvas = document.getElementById('matrix')
const ctx = canvas.getContext('2d')
canvas.width = window.innerWidth
canvas.height = window.innerHeight

const russian_letters = 'АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ'.split('')
const latin_letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'.split('')
const numbers = '0123456789'.split('')
const symbols = '!@#$%^&*()-_=+[]{}|;:",.<>?/`~'.split('')
const japanese_characters = 'アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン'.split('')
const korean_characters = '가나다라마바사아자차카타파하'.split('')
const greek_letters = 'ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩ'.split('')
const math_symbols = '∑∏√∞≈≠≤≥÷±∫∂∆∇∈∉∪∩⊂⊃⊆⊇'.split('')
const letters = ''
const all_characters = letters.concat(latin_letters, numbers, symbols, japanese_characters, korean_characters, greek_letters, math_symbols, russian_letters)


const font_size = 16
const columns = canvas.width / font_size
const drops = Array(Math.floor(columns)).fill(1)
function draw() {
  ctx.globalCompositeOperation = 'destination-out'
  ctx.fillStyle = 'rgba(0, 0, 0, 0.1)'
  ctx.fillRect(0, 0, canvas.width, canvas.height)
  ctx.globalCompositeOperation = 'source-over'

  ctx.fillStyle = '#FF5C00'
  ctx.font = font_size + 'px monospace'

  for (let i = 0; i < drops.length; i++) {
    const text = all_characters[Math.floor(Math.random() * all_characters.length)]
    ctx.fillText(text, i * font_size, drops[i] * font_size)

    if (drops[i] * font_size > canvas.height && Math.random() > 0.975) {
        drops[i] = 0
    }
    drops[i]++
  }
}
setInterval(draw, 33)

window.onresize = () => {
  canvas.width = window.innerWidth
  canvas.height = window.innerHeight
}
