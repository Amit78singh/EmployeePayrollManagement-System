import { TestBed } from '@angular/core/testing';

import { Payroll } from './payroll';

describe('Payroll', () => {
  let service: Payroll;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(Payroll);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });
});
