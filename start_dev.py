"""
项目启动脚本
用于快速启动开发环境
"""
import os
import sys
import subprocess
import time
from pathlib import Path

def run_command(cmd, cwd=None, background=False):
    """运行命令"""
    print(f"执行命令: {cmd}")
    if background:
        return subprocess.Popen(cmd, shell=True, cwd=cwd)
    else:
        result = subprocess.run(cmd, shell=True, cwd=cwd)
        return result.returncode == 0

def check_dependencies():
    """检查依赖"""
    print("检查依赖...")
    
    # 检查Python环境
    try:
        import uvicorn
        import fastapi
        import supabase
        print("✅ Python依赖已安装")
    except ImportError as e:
        print(f"❌ Python依赖缺失: {e}")
        print("请运行: cd spider && uv sync")
        return False
    
    # 检查Node.js环境
    admin_dir = Path("admin")
    if not (admin_dir / "node_modules").exists():
        print("❌ Node.js依赖缺失")
        print("请运行: cd admin && npm install")
        return False
    
    print("✅ Node.js依赖已安装")
    return True

def setup_environment():
    """设置环境"""
    print("设置环境...")
    
    # 检查spider环境配置
    spider_env = Path("spider/.env")
    if not spider_env.exists():
        print("⚠️  spider/.env 不存在，从示例文件复制...")
        spider_env_example = Path("spider/.env.example")
        if spider_env_example.exists():
            import shutil
            shutil.copy(spider_env_example, spider_env)
            print("✅ 已创建 spider/.env，请根据需要修改配置")
        else:
            print("❌ spider/.env.example 不存在")
            return False
    
    # 检查admin环境配置
    admin_env = Path("admin/.env.local")
    if not admin_env.exists():
        print("⚠️  admin/.env.local 不存在，创建默认配置...")
        with open(admin_env, "w") as f:
            f.write("VITE_API_URL=http://localhost:8000/api/v1\n")
        print("✅ 已创建 admin/.env.local")
    
    return True

def start_backend():
    """启动后端服务"""
    print("启动后端服务...")
    spider_dir = Path("spider")
    
    # 检查是否有uv
    try:
        subprocess.run(["uv", "--version"], check=True, capture_output=True)
        cmd = "uv run uvicorn main:app --reload --host 0.0.0.0 --port 8000"
    except (subprocess.CalledProcessError, FileNotFoundError):
        # 回退到python
        cmd = "python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000"
    
    return run_command(cmd, cwd=spider_dir, background=True)

def start_frontend():
    """启动前端服务"""
    print("启动前端服务...")
    admin_dir = Path("admin")
    
    # 检查是否有pnpm
    try:
        subprocess.run(["pnpm", "--version"], check=True, capture_output=True)
        cmd = "pnpm dev"
    except (subprocess.CalledProcessError, FileNotFoundError):
        # 回退到npm
        cmd = "npm run dev"
    
    return run_command(cmd, cwd=admin_dir, background=True)

def main():
    """主函数"""
    print("🚀 Price Memory 开发环境启动脚本")
    print("=" * 50)
    
    # 检查依赖
    if not check_dependencies():
        print("❌ 依赖检查失败，请先安装依赖")
        return 1
    
    # 设置环境
    if not setup_environment():
        print("❌ 环境设置失败")
        return 1
    
    # 启动服务
    print("\n启动服务...")
    
    # 启动后端
    backend_process = start_backend()
    if not backend_process:
        print("❌ 后端启动失败")
        return 1
    
    # 等待后端启动
    print("等待后端服务启动...")
    time.sleep(3)
    
    # 启动前端
    frontend_process = start_frontend()
    if not frontend_process:
        print("❌ 前端启动失败")
        backend_process.terminate()
        return 1
    
    print("\n✅ 服务启动成功!")
    print("📊 前端地址: http://localhost:5173")
    print("🔧 后端地址: http://localhost:8000")
    print("📚 API文档: http://localhost:8000/docs")
    print("\n按 Ctrl+C 停止服务")
    
    try:
        # 等待进程结束
        backend_process.wait()
        frontend_process.wait()
    except KeyboardInterrupt:
        print("\n🛑 正在停止服务...")
        backend_process.terminate()
        frontend_process.terminate()
        
        # 等待进程结束
        try:
            backend_process.wait(timeout=5)
            frontend_process.wait(timeout=5)
        except subprocess.TimeoutExpired:
            backend_process.kill()
            frontend_process.kill()
        
        print("✅ 服务已停止")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())