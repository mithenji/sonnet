defmodule ScorpiusSonnetWeb.Demos.ChristmasMeta.PageHTML do
  use ScorpiusSonnetWeb, :html

  def index(assigns) do
    ~H"""
    <div id="container-christmas-meta">
      <div class="video-container">
        <video
          class="christmas-video"
          autoplay
          loop
          muted
          playsinline
          src={VitePhx.media_path("static/videos/Christmas.MOV")}
        >
        </video>
      </div>
      <!-- Slider main container -->
      <div class="christmas-swiper">
        <!-- Additional required wrapper -->
        <div class="swiper-wrapper">
          <!-- Slides -->
          <div class="swiper-slide">
            <%!-- Slide 1 --%>
            <div class="operating-container absolute bottom-[80px] left-0 right-0 flex justify-center items-center">
              <div class="operating-item">
                <button class="operating-item-button" id="bullet-comment">
                  <span class="operating-item-button-text">
                    弹幕留言
                  </span>
                  <span class="button-gradient"></span>
                </button>
                <button class="operating-item-button" id="register-user">
                  <span class="operating-item-button-text">
                    登记用户信息
                  </span>
                  <span class="button-gradient"></span>
                </button>
              </div>
            </div>
          </div>
          <div class="swiper-slide BackgroundBlur">
            <%!-- Slide 2 --%>
            <div class="controller-container absolute top-0 left-0 right-0 flex justify-center items-center">
              <div class="controller-item">
                <button class="controller-item-button back-index">
                  <span class="controller-item-button-text">
                    返回首页
                  </span>
                  <span class="button-gradient"></span>
                </button>
              </div>
              <div class="controller-item"></div>
            </div>
            <div class="danmu-container h-screen flex flex-col justify-between items-center">
              <div class="scene-container w-full h-[300px]">
                <div class="screen w-full h-full"></div>
              </div>
              <div class="emitter-container w-full h-[150px] flex flex-col justify-center items-center p-0 relative">
                <div class="emitter-input-textarea w-full h-full p-[10px] pl-[15px]">
                  <textarea
                    class="w-full h-full border border-[#FFD700] rounded-[4px] bg-transparent focus:border-[#FFEA00] hover:border-[#FFEA00] active:border-[#FFEA00] focus:outline-none focus:ring-0 caret-[#FFEA00] p-[10px] pl-[15px]"
                    id="danmuInput"
                  ></textarea>
                </div>
                <div class="emitter-input-container">
                  <button class="emitter-input-button" id="sendDanmu">
                    <span class="emitter-input-button-text">
                      发送
                    </span>
                  </button>
                </div>
              </div>
            </div>
          </div>
          <div class="swiper-slide BackgroundBlur">
            <%!-- Slide 3 --%>
            <div class="controller-container absolute top-0 left-0 right-0 flex justify-center items-center">
              <div class="controller-item">
                <button class="controller-item-button back-index">
                  <span class="controller-item-button-text">
                    返回首页
                  </span>
                  <span class="button-gradient"></span>
                </button>
              </div>
              <div class="controller-item"></div>
            </div>
            <div class="register-user-container h-screen flex flex-col justify-center items-center">
              <form class="form-container bg-white p-6 rounded-lg shadow-md" id="registerUserForm">
                <h2 class="form-title text-lg font-bold mb-4">登记用户信息</h2>
                <div class="form-group mb-4">
                  <label for="nickname" class="form-label">昵称</label>
                  <input type="text" id="nickname" class="form-input" />
                </div>
                <div class="form-group mb-4">
                  <label for="email" class="form-label">邮箱</label>
                  <input type="email" id="email" class="form-input" />
                </div>
                <div class="form-group mb-4 flex">
                  <div class="country-code mr-2">
                    <label for="country" class="form-label">国家/地区</label>
                    <select id="country" class="form-input">
                      <option>+86</option>
                      <!-- Add more country codes as needed -->
                    </select>
                  </div>
                  <div class="phone-number flex-1">
                    <label for="phone" class="form-label">手机号</label>
                    <input type="text" id="phone" class="form-input" />
                  </div>
                </div>
                <div class="form-group mb-4">
                  <label for="terms" class="form-label">
                    <input type="checkbox" id="terms" class="form-checkbox" /> 同意并遵守
                  </label>
                  <p class="text-sm text-gray-600">我同意并遵守圣诞元宇宙活动规则和隐私政策。</p>
                </div>
                <button type="submit" class="form-submit-button" id="submitButton">提交</button>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
    <%= raw(VitePhx.vite_client("demos")) %>
    <link rel="stylesheet" href={VitePhx.css_path("demos/christmas-meta")} />
    <script type="module" src={VitePhx.asset_path("demos/christmas-meta/main.js")}>
    </script>
    """
  end

  def render("app.html", assigns) do
    ~H"""
    <.flash_group flash={@flash} />
    <%= @inner_content %>
    """
  end
end
