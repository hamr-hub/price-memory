#!/usr/bin/env python3
"""
Supabase Database Initialization Script
用于初始化 Supabase 数据库表结构的脚本
"""

import os
import sys
from pathlib import Path
from supabase import create_client, Client

def get_supabase_client() -> Client:
    """获取 Supabase 客户端"""
    url = os.environ.get("SUPABASE_URL")
    key = os.environ.get("SUPABASE_SERVICE_ROLE_KEY")  # 使用 service role key 进行管理操作
    
    if not url or not key:
        print("错误: 请设置 SUPABASE_URL 和 SUPABASE_SERVICE_ROLE_KEY 环境变量")
        sys.exit(1)
    
    return create_client(url, key)

def read_sql_file(file_path: Path) -> str:
    """读取 SQL 文件内容"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return f.read()
    except FileNotFoundError:
        print(f"错误: 找不到文件 {file_path}")
        sys.exit(1)

def execute_sql(client: Client, sql: str, description: str):
    """执行 SQL 语句"""
    print(f"正在执行: {description}")
    try:
        # 注意: Supabase Python 客户端主要用于数据操作，不直接支持 DDL
        # 对于建表操作，建议使用 Supabase Dashboard 或 CLI
        print(f"SQL 内容:\n{sql}")
        print("注意: 请将上述 SQL 复制到 Supabase Dashboard 的 SQL Editor 中执行")
        print("或者使用 Supabase CLI: supabase db push")
    except Exception as e:
        print(f"执行失败: {e}")
        return False
    return True

def main():
    """主函数"""
    print("=== Supabase 数据库初始化脚本 ===")
    
    # 获取脚本所在目录
    script_dir = Path(__file__).parent
    migrations_dir = script_dir / "migrations"
    
    if not migrations_dir.exists():
        print(f"错误: 迁移目录不存在 {migrations_dir}")
        sys.exit(1)
    
    # 获取 Supabase 客户端
    client = get_supabase_client()
    
    # 按顺序执行迁移文件
    migration_files = sorted(migrations_dir.glob("*.sql"))
    
    if not migration_files:
        print("警告: 没有找到迁移文件")
        return
    
    print(f"找到 {len(migration_files)} 个迁移文件")
    
    for migration_file in migration_files:
        print(f"\n--- 处理迁移文件: {migration_file.name} ---")
        sql_content = read_sql_file(migration_file)
        
        success = execute_sql(
            client, 
            sql_content, 
            f"执行迁移 {migration_file.name}"
        )
        
        if not success:
            print(f"迁移失败: {migration_file.name}")
            break
    
    print("\n=== 初始化完成 ===")
    print("\n使用说明:")
    print("1. 复制上述 SQL 到 Supabase Dashboard 的 SQL Editor")
    print("2. 或者使用 Supabase CLI:")
    print("   - supabase init (如果还未初始化)")
    print("   - 将 SQL 文件放到 supabase/migrations/ 目录")
    print("   - supabase db push")

if __name__ == "__main__":
    main()