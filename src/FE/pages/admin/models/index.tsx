import React, { useEffect, useState } from 'react';

import useTranslation from '@/hooks/useTranslation';

import { formatNumberAsMoney } from '@/utils/common';

import {
  AdminModelDto,
  GetModelKeysResult,
  SimpleModelReferenceDto,
} from '@/types/adminApis';
import { feModelProviders } from '@/types/model';

import { Button } from '@/components/ui/button';
import { Card } from '@/components/ui/card';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';

import AddModelModal from '../_components/Models/AddModelModal';
import EditModelModal from '../_components/Models/EditModelModal';

import {
  getModelKeys,
  getModelProviderModels,
  getModels,
} from '@/apis/adminApis';

export default function Models() {
  const { t } = useTranslation();
  const [isOpen, setIsOpen] = useState({ add: false, edit: false });
  const [selectedModel, setSelectedModel] = useState<AdminModelDto>();
  const [models, setModels] = useState<AdminModelDto[]>([]);
  const [loading, setLoading] = useState(true);
  const [modelKeys, setModelKeys] = useState<GetModelKeysResult[]>([]);
  const [modelVersions, setModelVersions] = useState<SimpleModelReferenceDto[]>(
    [],
  );

  useEffect(() => {
    init();
  }, []);

  const init = () => {
    getModels().then((data) => {
      setModels(data);
      setIsOpen({ add: false, edit: false });
      setSelectedModel(undefined);
      setLoading(false);
    });
    getModelKeys().then((data) => {
      setModelKeys(data);
    });
  };

  const showEditDialog = (item: AdminModelDto) => {
    getModelProviderModels(item.modelProviderId).then((possibleModels) => {
      setModelVersions(possibleModels);
      setSelectedModel(item);
      setIsOpen({ ...isOpen, edit: true });
    });
  };

  const showCreateDialog = () => {
    setIsOpen({ ...isOpen, add: true });
  };

  const handleClose = () => {
    setIsOpen({ add: false, edit: false });
    setSelectedModel(undefined);
  };

  return (
    <>
      <div className="flex flex-col gap-4 mb-4">
        <div className="flex justify-end gap-3 items-center">
          <Button
            onClick={() => {
              showCreateDialog();
            }}
            color="primary"
          >
            {t('Add Model')}
          </Button>
        </div>
      </div>
      <Card>
        <Table>
          <TableHeader>
            <TableRow>
              <TableHead className="w-20">{t('Rank')}</TableHead>
              <TableHead>{t('Model Display Name')}</TableHead>
              <TableHead>{t('Model Key')}</TableHead>
              <TableHead>{t('Model Version')}</TableHead>
              <TableHead>{t('Token Price')}</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody isLoading={loading} isEmpty={models.length === 0}>
            {models.map((item) => (
              <TableRow
                className="cursor-pointer"
                key={item.modelId}
                onClick={() => showEditDialog(item)}
              >
                <TableCell>{item.rank}</TableCell>
                <TableCell>
                  <div className="flex items-center gap-1 ">
                    <div
                      className={`w-2 h-2 rounded-full ${
                        item.enabled ? 'bg-green-400' : 'bg-gray-400'
                      }`}
                    ></div>
                    {item.name}
                  </div>
                </TableCell>
                <TableCell>
                  {modelKeys.find((k) => k.id === item.modelKeyId)?.name}
                </TableCell>
                <TableCell>{item.modelReferenceName}</TableCell>
                <TableCell>
                  {'￥' +
                    formatNumberAsMoney(item.inputTokenPrice1M) +
                    '/' +
                    formatNumberAsMoney(item.outputTokenPrice1M)}
                </TableCell>
              </TableRow>
            ))}
          </TableBody>
        </Table>
      </Card>
      {isOpen.edit && (
        <EditModelModal
          selected={selectedModel!}
          modelKeys={modelKeys}
          modelVersionList={modelVersions}
          isOpen={isOpen.edit}
          onClose={handleClose}
          onSuccessful={init}
        />
      )}
      {isOpen.add && (
        <AddModelModal
          modelKeys={modelKeys}
          isOpen={isOpen.add}
          onClose={handleClose}
          onSuccessful={init}
        />
      )}
    </>
  );
}
