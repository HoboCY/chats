export interface UserModelConfig {
  prompt: string | null;
  temperature: number | null;
  enableSearch: boolean | null;
}

export enum DBModelProvider {
  Test = 0,
  Azure = 1,
  HunYuan = 2,
  LingYi = 3,
  Moonshot = 4,
  OpenAI = 5,
  QianFan = 6,
  QianWen = 7,
  Spark = 8,
  ZhiPuAI = 9,
  DeepSeek = 10,
  X_AI = 11,
  GithubModels = 12,
  GoogleAI = 13,
}

export type FEModelProvider = {
  id: number;
  name: string;
  icon: string;
};

export const feModelProviders: FEModelProvider[] = [
  { id: DBModelProvider.Test, name: 'Test', icon: '/icons/logo.png' },
  { id: DBModelProvider.Azure, name: 'Azure OpenAI', icon: '/logos/azure.svg' },
  { id: DBModelProvider.HunYuan, name: 'Tencent Hunyuan', icon: '/logos/hunyuan.svg' },
  { id: DBModelProvider.LingYi, name: '01.ai', icon: '/logos/lingyi.svg' },
  { id: DBModelProvider.Moonshot, name: 'Moonshot', icon: '/logos/moonshot.svg' },
  { id: DBModelProvider.OpenAI, name: 'OpenAI', icon: '/logos/openai.svg' },
  { id: DBModelProvider.QianFan, name: 'Wenxin Qianfan', icon: '/logos/qianfan.svg' },
  { id: DBModelProvider.QianWen, name: 'DashScope', icon: '/logos/qianwen.svg' },
  { id: DBModelProvider.Spark, name: 'Xunfei SparkDesk', icon: '/logos/spark.svg' },
  { id: DBModelProvider.ZhiPuAI, name: 'Zhipu AI', icon: '/logos/zhipuai.svg' },
  { id: DBModelProvider.DeepSeek, name: 'DeepSeek', icon: '/logos/deepseek.svg' },
  { id: DBModelProvider.X_AI, name: 'x.ai', icon: '/logos/x.svg' },
  { id: DBModelProvider.GithubModels, name: 'Github Models', icon: '/logos/github.svg' },
  { id: DBModelProvider.GoogleAI, name: 'Google AI', icon: '/logos/google.svg' },
];

export interface ChatModelFileConfig {
  maxSize: number;
  count: number;
}

export interface ChatModelPriceConfig {
  input: number;
  out: number;
}
