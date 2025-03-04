// 导入样式
import './styles/index.css';

// 初始化页面交互
document.addEventListener('DOMContentLoaded', () => {
  console.log('Demos Index Page Loaded');
  
  // 添加卡片点击效果
  const demoCards = document.querySelectorAll('.demo-card');
  demoCards.forEach(card => {
    card.addEventListener('click', (e) => {
      // 如果点击的是链接内部，不做额外处理
      if (e.target.tagName === 'A' || e.target.closest('a')) {
        return;
      }
      
      // 否则，找到卡片内的链接并模拟点击
      const link = card.querySelector('a');
      if (link) {
        link.click();
      }
    });
  });
}); 