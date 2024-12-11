<template>
  <div class="counter-demo">
    <h1>Counter Demo</h1>
    <div class="counter">
      <button @click="count--">-</button>
      <span>{{ count }}</span>
      <button @click="count++">+</button>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const count = ref(0)
</script>

<style>
.counter-demo {
  padding: 2rem;
  text-align: center;
}

.counter {
  display: flex;
  gap: 1rem;
  justify-content: center;
  align-items: center;
  margin-top: 1rem;
}

button {
  padding: 0.5rem 1rem;
  font-size: 1.2rem;
  border-radius: 0.25rem;
}
</style> 