export const Player = {
  player: null,

  init(domId, playerId, onReady) {
    window.onYouTubePlayerAPIReady = () => {
      console.log('lol')
      this.onIframeReady(domId, playerId, onReady)
    }

    const youtubeScriptTag = document.createElement('script')
    youtubeScriptTag.src = '//www.youtube.com/iframe_api'
    document.head.appendChild(youtubeScriptTag)
    console.log('lol2')
  },

  onIframeReady(domId, playerId, onReady) {
    this.player = new YT.Player(domId, {
      height: '360',
      width: '420',
      videoId: playerId,
      events: {
        onReady: event => onReady(event),
        onStateChange: event => this.onPlayerStateChange(event)
      }
    })

    console.log('data:', {player: this.player, domId, playerId, onReady})
  },

  onPlayerStateChange(event) {

  },

  getCurrentTime() {
    return Math.floor(this.player.getCurrentTime() * 1000)
  },

  seekTo(milleseconds) {
    return this.player.seekTo(milleseconds / 1000)
  }
}