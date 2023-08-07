(function () {
  let baseColor = "white",
    showColor = "#09f",
    hoverColor = "#f60"

  function tocTokens2HTML(tokens) {
    let html = "<ul>",
      index = 0,
      level = 1,
      levelStack = ['</ul>']

    let tokensLength = tokens.length
    if (!tokensLength) return ""
    while (index < tokensLength) {
      if (tokens[index].level == level) {
        if (levelStack[levelStack.length - 1] == '</li>') {
          html += levelStack.pop() // html += '</li>'
        }
        html += `<li class="ml-${level * 2}"><a href="#${tokens[index].anchor}" index="${index}">${tokens[index].text}</a>`

        levelStack.push(`</li>`)
        index++
      } else if (tokens[index].level > level) {
        if (levelStack[levelStack.length - 1] == '</ul>') {
          html += `<li><ul>`
          levelStack.push(`</li>`)
          levelStack.push(`</ul>`)
        } else {
          html += `<ul>`
          levelStack.push('</ul>')
        }
        level++
      } else {
        for (let i = (level - tokens[index].level) * 2 + 1; i > 0; i--) {
          html += levelStack.pop()
        }
        level = tokens[index].level
      }
    }
    for (let i = levelStack.length; i > 0; i--) {
      html += levelStack.pop()
    }
    return html
  }

  let chain = function () {
    return {
      anchorDOM: null,
      anchors: [],
      tocDOM: null,
      tocs: [],
      length: 0,
      index: 0,
      init: init,
      scroll: scroll
    }
  }

  function init(tocDOM_Name = 'markdown-toc', anchorDOM_Name = 'markdown-body', anchors_Name = 'markdown-body-anchor') {
    this.anchorDOM = document.getElementById(anchorDOM_Name)
    this.anchors = this.anchorDOM.getElementsByClassName(anchors_Name)
    this.tocDOM = document.getElementById(tocDOM_Name)
    this.tocs = this.tocDOM.querySelectorAll('a[href^="#"]')
    this.length = this.tocs.length

    if (!this.length) return
    this.tocs[this.index].style.color = showColor
    this.tocs.forEach(anchor => {
      function scrollToBodyIndex(id){
        let step = 80, distance = 45, speed = 10 // step < distance * 2
        let goalDom = document.getElementById(id.slice(1)),
          goal = goalDom.offsetTop - distance,
          now = document.documentElement.scrollTop + document.body.scrollTop

        step = goal > now ? step : -step
        let s = setInterval(function () {
          if (Math.abs(goal - now) < distance) {
            clearInterval(s)
            window.scrollTo(0, goal) // 修正
            window.location.hash = id // 为了修改 URL 也是不容易
          } else {
            now += step
            window.scrollBy(0, step)
          }
        }, speed)
      }
      anchor.addEventListener('click', function (e) {
        e.preventDefault();
        scrollToBodyIndex(this.getAttribute('href'))
        // 如果不需要在平滑滚动后修改 URL，下面这一句就够了
        // document.querySelector(this.getAttribute('href')).scrollIntoView({
        //   behavior: 'smooth'
        // })
      })
    })
  }

  function scroll() {
    if (!this.length) return
    let anchors = this.anchors,
      tocs = this.tocs,
      length = this.length,
      index = this.index

    function top(e) {
      return e.getBoundingClientRect().top
    }

    function toggleFontColor(dom, last, now) {
      dom[last].style.color = baseColor
      dom[now].style.color = showColor
    }

    let scrollToTocIndex = () => {
      let goal = window.innerHeight / 3,
        now = top(tocs[index])
      if (Math.abs(goal - now) > 10) {
        this.tocDOM.scrollTop += now - goal;
      }
    }

    let distance = 45
    if (top(anchors[index]) < distance) {
      if (index > length - 2) return
      if (top(anchors[index + 1]) > distance) return
      toggleFontColor(tocs, this.index++, this.index)
      scrollToTocIndex()
    } else {
      if (index < 1) return
      // 一旦 now > distance 就已经进入上一个标题内容了
      toggleFontColor(tocs, this.index--, this.index)
      scrollToTocIndex()
    }
  }

  return markdownToc = {
    toHTML: tocTokens2HTML,
    chain: chain()
  }
})()