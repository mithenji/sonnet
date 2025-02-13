<template>
  <div class="demo-container christmas-demo">
    <h1 class="text-2xl font-bold text-center my-4">Christmas Demo</h1>
    <div class="flex justify-center">
      <div class="christmas-tree text-center">
        🎄
        <div class="mt-2">
          Merry Christmas!
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
// 组件逻辑
</script>

<style scoped>
.christmas-demo {
  background: linear-gradient(to bottom, #ffffff, #f0f0f0);
}

.christmas-tree {
  font-size: 4rem;
  animation: bounce 2s infinite;
}

@keyframes bounce {
  0%, 100% { transform: translateY(0); }
  50% { transform: translateY(-10px); }
}
</style> 