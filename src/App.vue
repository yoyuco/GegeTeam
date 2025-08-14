<template>
  <div class="min-h-screen flex bg-neutral-50 text-neutral-900">
    <aside class="w-64 hidden md:block border-r border-neutral-200 p-4">
      <nav class="space-y-2">
        <RouterLink to="/" class="block">🏠 Dashboard</RouterLink>
        <RouterLink to="/sales" class="block">💰 Bán hàng</RouterLink>
        <RouterLink to="/orders" class="block">📦 Đơn hàng</RouterLink>
        <RouterLink to="/customers" class="block">👥 Khách hàng</RouterLink>
        <RouterLink to="/employees" class="block">🧑‍💼 Nhân viên</RouterLink>
        <RouterLink to="/tasks" class="block">🗂️ Kanban</RouterLink>
        <RouterLink to="/kpi" class="block">📈 KPI</RouterLink>
        <RouterLink to="/auth" class="block">🔐 Đăng nhập</RouterLink>
      </nav>
    </aside>
    <main class="flex-1 p-4">
      <RouterView />
    </main>
  </div>
</template>
<script setup lang="ts"></script>
