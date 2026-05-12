---
layout: page
title: "游戏策划文章"
---

<h1>游戏策划目录</h1>

<ul>
{% for post in site.Games %}
  <li>
    <a href="{{ post.url | relative_url }}">{{ post.title }}</a>
  </li>
{% endfor %}
</ul>
