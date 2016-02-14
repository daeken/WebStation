/* Autogenerated from insts.td. DO NOT EDIT */
function interpret($pc, inst, state) {
	switch((inst) >>> (0x1a)) {
		case 0x0: {
			switch((inst) & (0x3f)) {
				case 0x0: {
					/* SLL */
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					$shamt = ((inst) >>> (0x6)) & (0x1f);
					if(($rd) != (0x0)) { (state.regs)[$rd] = (((state.regs)[$rt]) << ($shamt)) >>> (0x0); }
					return(true);
					break;
				}
				case 0x2: {
					/* SRL */
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					$shamt = ((inst) >>> (0x6)) & (0x1f);
					if(($rd) != (0x0)) { (state.regs)[$rd] = ((state.regs)[$rt]) >>> ($shamt); }
					return(true);
					break;
				}
				case 0x3: {
					/* SRA */
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					$shamt = ((inst) >>> (0x6)) & (0x1f);
					if(($rd) != (0x0)) { (state.regs)[$rd] = ((state.regs)[$rt]) >> ($shamt); }
					return(true);
					break;
				}
				case 0x4: {
					/* SLLV */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rd) != (0x0)) { (state.regs)[$rd] = (((state.regs)[$rt]) << ((state.regs)[$rs])) >>> (0x0); }
					return(true);
					break;
				}
				case 0x6: {
					/* SRLV */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rd) != (0x0)) { (state.regs)[$rd] = ((state.regs)[$rt]) >>> ((state.regs)[$rs]); }
					return(true);
					break;
				}
				case 0x7: {
					/* SRAV */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rd) != (0x0)) { (state.regs)[$rd] = ((state.regs)[$rt]) >> ((state.regs)[$rs]); }
					return(true);
					break;
				}
				case 0x8: {
					/* JR */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					state.branch(((state.regs)[$rs]) >>> (0x0));
					return(true);
					break;
				}
				case 0x9: {
					/* JALR */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rd) != (0x0)) { (state.regs)[$rd] = (($pc) + (0x4)) + (0x4); }
					state.branch(((state.regs)[$rs]) >>> (0x0));
					return(true);
					break;
				}
				case 0xc: {
					/* SYSCALL */
					$code = ((inst) >>> (0x6)) & (0xfffff);
					state.syscall($code);
					return(true);
					break;
				}
				case 0xd: {
					/* BREAK */
					$code = ((inst) >>> (0x6)) & (0xfffff);
					state.break_($code);
					return(true);
					break;
				}
				case 0x10: {
					/* MFHI */
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rd) != (0x0)) { (state.regs)[$rd] = state.hi; }
					return(true);
					break;
				}
				case 0x11: {
					/* MTHI */
					$rd = ((inst) >>> (0xb)) & (0x1f);
					state.hi = (state.regs)[$rd];
					return(true);
					break;
				}
				case 0x12: {
					/* MFLO */
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rd) != (0x0)) { (state.regs)[$rd] = state.lo; }
					return(true);
					break;
				}
				case 0x13: {
					/* MTLO */
					$rd = ((inst) >>> (0xb)) & (0x1f);
					state.lo = (state.regs)[$rd];
					return(true);
					break;
				}
				case 0x18: {
					/* MULT */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$_t = ((state.regs)[$rs]) * ((state.regs)[$rt]);
					state.lo = (($_t) & (0xffffffff)) >>> (0x0);
					state.hi = ($_t) >>> (0x20);
					return(true);
					break;
				}
				case 0x19: {
					/* MULTU */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$_t = (((state.regs)[$rs]) >>> (0x0)) * (((state.regs)[$rt]) >>> (0x0));
					state.lo = (($_t) & (0xffffffff)) >>> (0x0);
					state.hi = ($_t) >>> (0x20);
					return(true);
					break;
				}
				case 0x1a: {
					/* DIV */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					state.lo = (((state.regs)[$rs]) / ((state.regs)[$rt])) >>> (0x0);
					state.hi = (((state.regs)[$rs]) % ((state.regs)[$rt])) >>> (0x0);
					return(true);
					break;
				}
				case 0x1b: {
					/* DIVU */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					state.lo = ((((state.regs)[$rs]) >>> (0x0)) / (((state.regs)[$rt]) >>> (0x0))) >>> (0x0);
					state.hi = ((((state.regs)[$rs]) >>> (0x0)) % (((state.regs)[$rt]) >>> (0x0))) >>> (0x0);
					return(true);
					break;
				}
				case 0x20: {
					/* ADD */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(overflow(((state.regs)[$rs]) + ((state.regs)[$rt]))) {
						state.raise(ArithmeticOverflow);
					} else {
						if(($rd) != (0x0)) { (state.regs)[$rd] = ((state.regs)[$rs]) + ((state.regs)[$rt]); }
					}
					return(true);
					break;
				}
				case 0x21: {
					/* ADDU */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rd) != (0x0)) { (state.regs)[$rd] = ((state.regs)[$rs]) + ((state.regs)[$rt]); }
					return(true);
					break;
				}
				case 0x22: {
					/* SUB */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(overflow(((state.regs)[$rs]) - ((state.regs)[$rt]))) {
						state.raise(ArithmeticOverflow);
					} else {
						if(($rd) != (0x0)) { (state.regs)[$rd] = ((state.regs)[$rs]) - ((state.regs)[$rt]); }
					}
					return(true);
					break;
				}
				case 0x23: {
					/* SUBU */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rd) != (0x0)) { (state.regs)[$rd] = ((state.regs)[$rs]) - ((state.regs)[$rt]); }
					return(true);
					break;
				}
				case 0x24: {
					/* AND */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rd) != (0x0)) { (state.regs)[$rd] = (((state.regs)[$rs]) & ((state.regs)[$rt])) >>> (0x0); }
					return(true);
					break;
				}
				case 0x25: {
					/* OR */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rd) != (0x0)) { (state.regs)[$rd] = (((state.regs)[$rs]) | ((state.regs)[$rt])) >>> (0x0); }
					return(true);
					break;
				}
				case 0x26: {
					/* XOR */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rd) != (0x0)) { (state.regs)[$rd] = (((state.regs)[$rs]) ^ ((state.regs)[$rt])) >>> (0x0); }
					return(true);
					break;
				}
				case 0x27: {
					/* NOR */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rd) != (0x0)) { (state.regs)[$rd] = (~(((state.regs)[$rs]) | ((state.regs)[$rt]))) >>> (0x0); }
					return(true);
					break;
				}
				case 0x2a: {
					/* SLT */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if((((state.regs)[$rs]) | (0x0)) < (((state.regs)[$rt]) | (0x0))) {
						if(($rd) != (0x0)) { (state.regs)[$rd] = 0x1; }
					} else {
						if(($rd) != (0x0)) { (state.regs)[$rd] = 0x0; }
					}
					return(true);
					break;
				}
				case 0x2b: {
					/* SLTU */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if((((state.regs)[$rs]) >>> (0x0)) < (((state.regs)[$rt]) >>> (0x0))) {
						if(($rd) != (0x0)) { (state.regs)[$rd] = 0x1; }
					} else {
						if(($rd) != (0x0)) { (state.regs)[$rd] = 0x0; }
					}
					return(true);
					break;
				}
			}
			break;
		}
		case 0x1: {
			switch(((inst) >>> (0x10)) & (0x1f)) {
				case 0x0: {
					/* BLTZ */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$imm = (inst) & (0xffff);
					$target = (($pc) + (0x4)) + (signext(0x12, (($imm) << (0x2)) >>> (0x0)));
					if((((state.regs)[$rs]) | (0x0)) < (0x0)) { state.branch($target); }
					return(true);
					break;
				}
				case 0x1: {
					/* BGEZ */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$imm = (inst) & (0xffff);
					$target = (($pc) + (0x4)) + (signext(0x12, (($imm) << (0x2)) >>> (0x0)));
					if((((state.regs)[$rs]) | (0x0)) >= (0x0)) { state.branch($target); }
					return(true);
					break;
				}
				case 0x10: {
					/* BLTZAL */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$imm = (inst) & (0xffff);
					if((0x1f) != (0x0)) { (state.regs)[0x1f] = ($pc) + (0x4); }
					$target = (($pc) + (0x4)) + (signext(0x12, (($imm) << (0x2)) >>> (0x0)));
					if((((state.regs)[$rs]) | (0x0)) < (0x0)) { state.branch($target); }
					return(true);
					break;
				}
				case 0x11: {
					/* BGEZAL */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$imm = (inst) & (0xffff);
					if((0x1f) != (0x0)) { (state.regs)[0x1f] = ($pc) + (0x4); }
					$target = (($pc) + (0x4)) + (signext(0x12, (($imm) << (0x2)) >>> (0x0)));
					if((((state.regs)[$rs]) | (0x0)) >= (0x0)) { state.branch($target); }
					return(true);
					break;
				}
			}
			break;
		}
		case 0x2: {
			/* J */
			$imm = (inst) & (0x3ffffff);
			$target = (((($pc) + (0x4)) & (0xf0000000)) >>> (0x0)) + (zeroext(0x1c, (($imm) << (0x2)) >>> (0x0)));
			state.branch($target);
			return(true);
			break;
		}
		case 0x3: {
			/* JAL */
			$imm = (inst) & (0x3ffffff);
			if((0x1f) != (0x0)) { (state.regs)[0x1f] = (($pc) + (0x4)) + (0x4); }
			$target = (((($pc) + (0x4)) & (0xf0000000)) >>> (0x0)) + (zeroext(0x1c, (($imm) << (0x2)) >>> (0x0)));
			state.branch($target);
			return(true);
			break;
		}
		case 0x4: {
			/* BEQ */
			$rs = ((inst) >>> (0x15)) & (0x1f);
			$rt = ((inst) >>> (0x10)) & (0x1f);
			$imm = (inst) & (0xffff);
			$target = (($pc) + (0x4)) + (signext(0x12, (($imm) << (0x2)) >>> (0x0)));
			if((((state.regs)[$rs]) >>> (0x0)) == (((state.regs)[$rt]) >>> (0x0))) { state.branch($target); }
			return(true);
			break;
		}
		case 0x5: {
			/* BNE */
			$rs = ((inst) >>> (0x15)) & (0x1f);
			$rt = ((inst) >>> (0x10)) & (0x1f);
			$imm = (inst) & (0xffff);
			$target = (($pc) + (0x4)) + (signext(0x12, (($imm) << (0x2)) >>> (0x0)));
			if(((state.regs)[$rs]) != ((state.regs)[$rt])) { state.branch($target); }
			return(true);
			break;
		}
		case 0x6: {
			switch(((inst) >>> (0x10)) & (0x1f)) {
				case 0x0: {
					/* BLEZ */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$imm = (inst) & (0xffff);
					$target = (($pc) + (0x4)) + (signext(0x12, (($imm) << (0x2)) >>> (0x0)));
					if((((state.regs)[$rs]) | (0x0)) <= (0x0)) { state.branch($target); }
					return(true);
					break;
				}
			}
			break;
		}
		case 0x7: {
			switch(((inst) >>> (0x10)) & (0x1f)) {
				case 0x0: {
					/* BGTZ */
					$rs = ((inst) >>> (0x15)) & (0x1f);
					$imm = (inst) & (0xffff);
					$target = (($pc) + (0x4)) + (signext(0x12, (($imm) << (0x2)) >>> (0x0)));
					if((((state.regs)[$rs]) | (0x0)) > (0x0)) { state.branch($target); }
					return(true);
					break;
				}
			}
			break;
		}
		case 0x8: {
			/* ADDI */
			$rs = ((inst) >>> (0x15)) & (0x1f);
			$rt = ((inst) >>> (0x10)) & (0x1f);
			$imm = (inst) & (0xffff);
			$eimm = signext(0x10, $imm);
			if(overflow(((state.regs)[$rs]) + ($eimm))) {
				state.raise(ArithmeticOverflow);
			} else {
				if(($rt) != (0x0)) { (state.regs)[$rt] = ((state.regs)[$rs]) + ($eimm); }
			}
			return(true);
			break;
		}
		case 0x9: {
			/* ADDIU */
			$rs = ((inst) >>> (0x15)) & (0x1f);
			$rt = ((inst) >>> (0x10)) & (0x1f);
			$imm = (inst) & (0xffff);
			$eimm = signext(0x10, $imm);
			if(($rt) != (0x0)) { (state.regs)[$rt] = ((state.regs)[$rs]) + ($eimm); }
			return(true);
			break;
		}
		case 0xa: {
			/* SLTI */
			$rs = ((inst) >>> (0x15)) & (0x1f);
			$rt = ((inst) >>> (0x10)) & (0x1f);
			$imm = (inst) & (0xffff);
			$eimm = signext(0x10, $imm);
			if((((state.regs)[$rs]) | (0x0)) < ($eimm)) {
				if(($rt) != (0x0)) { (state.regs)[$rt] = 0x1; }
			} else {
				if(($rt) != (0x0)) { (state.regs)[$rt] = 0x0; }
			}
			return(true);
			break;
		}
		case 0xb: {
			/* SLTIU */
			$rs = ((inst) >>> (0x15)) & (0x1f);
			$rt = ((inst) >>> (0x10)) & (0x1f);
			$imm = (inst) & (0xffff);
			$eimm = (signext(0x10, $imm)) >>> (0x0);
			if((((state.regs)[$rs]) >>> (0x0)) < ($eimm)) {
				if(($rt) != (0x0)) { (state.regs)[$rt] = 0x1; }
			} else {
				if(($rt) != (0x0)) { (state.regs)[$rt] = 0x0; }
			}
			return(true);
			break;
		}
		case 0xc: {
			/* ANDI */
			$rs = ((inst) >>> (0x15)) & (0x1f);
			$rt = ((inst) >>> (0x10)) & (0x1f);
			$imm = (inst) & (0xffff);
			$eimm = zeroext(0x10, $imm);
			if(($rt) != (0x0)) { (state.regs)[$rt] = (((state.regs)[$rs]) & ($eimm)) >>> (0x0); }
			return(true);
			break;
		}
		case 0xd: {
			/* ORI */
			$rs = ((inst) >>> (0x15)) & (0x1f);
			$rt = ((inst) >>> (0x10)) & (0x1f);
			$imm = (inst) & (0xffff);
			$eimm = zeroext(0x10, $imm);
			if(($rt) != (0x0)) { (state.regs)[$rt] = (((state.regs)[$rs]) | ($eimm)) >>> (0x0); }
			return(true);
			break;
		}
		case 0xe: {
			/* XORI */
			$rs = ((inst) >>> (0x15)) & (0x1f);
			$rt = ((inst) >>> (0x10)) & (0x1f);
			$imm = (inst) & (0xffff);
			$eimm = zeroext(0x10, $imm);
			if(($rt) != (0x0)) { (state.regs)[$rt] = (((state.regs)[$rs]) ^ ($eimm)) >>> (0x0); }
			return(true);
			break;
		}
		case 0xf: {
			/* LUI */
			$rt = ((inst) >>> (0x10)) & (0x1f);
			$imm = (inst) & (0xffff);
			if(($rt) != (0x0)) { (state.regs)[$rt] = (($imm) << (0x10)) >>> (0x0); }
			return(true);
			break;
		}
		case 0x10: {
			switch(((inst) >>> (0x15)) & (0x1f)) {
				case 0x0: {
					/* MFCzanonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rt) != (0x0)) { (state.regs)[$rt] = state.copreg($cop, $rd); }
					return(true);
					break;
				}
				case 0x2: {
					/* CFCzanonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rt) != (0x0)) { (state.regs)[$rt] = state.copcreg($cop, $rd); }
					return(true);
					break;
				}
				case 0x4: {
					/* MTCzanonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					state.copreg($cop, $rd, (state.regs)[$rt]);
					return(true);
					break;
				}
				case 0x6: {
					/* CTCzanonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					state.copcreg($cop, $rd, (state.regs)[$rt]);
					return(true);
					break;
				}
				case 0x10: {
					/* COPzanonymous_4anonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x11: {
					/* COPzanonymous_5anonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x12: {
					/* COPzanonymous_6anonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x13: {
					/* COPzanonymous_7anonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x14: {
					/* COPzanonymous_8anonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x15: {
					/* COPzanonymous_9anonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x16: {
					/* COPzanonymous_10anonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x17: {
					/* COPzanonymous_11anonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x18: {
					/* COPzanonymous_12anonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x19: {
					/* COPzanonymous_13anonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1a: {
					/* COPzanonymous_14anonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1b: {
					/* COPzanonymous_15anonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1c: {
					/* COPzanonymous_16anonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1d: {
					/* COPzanonymous_17anonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1e: {
					/* COPzanonymous_18anonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1f: {
					/* COPzanonymous_19anonymous_0 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
			}
			break;
		}
		case 0x11: {
			switch(((inst) >>> (0x15)) & (0x1f)) {
				case 0x0: {
					/* MFCzanonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rt) != (0x0)) { (state.regs)[$rt] = state.copreg($cop, $rd); }
					return(true);
					break;
				}
				case 0x2: {
					/* CFCzanonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rt) != (0x0)) { (state.regs)[$rt] = state.copcreg($cop, $rd); }
					return(true);
					break;
				}
				case 0x4: {
					/* MTCzanonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					state.copreg($cop, $rd, (state.regs)[$rt]);
					return(true);
					break;
				}
				case 0x6: {
					/* CTCzanonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					state.copcreg($cop, $rd, (state.regs)[$rt]);
					return(true);
					break;
				}
				case 0x10: {
					/* COPzanonymous_4anonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x11: {
					/* COPzanonymous_5anonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x12: {
					/* COPzanonymous_6anonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x13: {
					/* COPzanonymous_7anonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x14: {
					/* COPzanonymous_8anonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x15: {
					/* COPzanonymous_9anonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x16: {
					/* COPzanonymous_10anonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x17: {
					/* COPzanonymous_11anonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x18: {
					/* COPzanonymous_12anonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x19: {
					/* COPzanonymous_13anonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1a: {
					/* COPzanonymous_14anonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1b: {
					/* COPzanonymous_15anonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1c: {
					/* COPzanonymous_16anonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1d: {
					/* COPzanonymous_17anonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1e: {
					/* COPzanonymous_18anonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1f: {
					/* COPzanonymous_19anonymous_1 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
			}
			break;
		}
		case 0x12: {
			switch(((inst) >>> (0x15)) & (0x1f)) {
				case 0x0: {
					/* MFCzanonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rt) != (0x0)) { (state.regs)[$rt] = state.copreg($cop, $rd); }
					return(true);
					break;
				}
				case 0x2: {
					/* CFCzanonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rt) != (0x0)) { (state.regs)[$rt] = state.copcreg($cop, $rd); }
					return(true);
					break;
				}
				case 0x4: {
					/* MTCzanonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					state.copreg($cop, $rd, (state.regs)[$rt]);
					return(true);
					break;
				}
				case 0x6: {
					/* CTCzanonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					state.copcreg($cop, $rd, (state.regs)[$rt]);
					return(true);
					break;
				}
				case 0x10: {
					/* COPzanonymous_4anonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x11: {
					/* COPzanonymous_5anonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x12: {
					/* COPzanonymous_6anonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x13: {
					/* COPzanonymous_7anonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x14: {
					/* COPzanonymous_8anonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x15: {
					/* COPzanonymous_9anonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x16: {
					/* COPzanonymous_10anonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x17: {
					/* COPzanonymous_11anonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x18: {
					/* COPzanonymous_12anonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x19: {
					/* COPzanonymous_13anonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1a: {
					/* COPzanonymous_14anonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1b: {
					/* COPzanonymous_15anonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1c: {
					/* COPzanonymous_16anonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1d: {
					/* COPzanonymous_17anonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1e: {
					/* COPzanonymous_18anonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1f: {
					/* COPzanonymous_19anonymous_2 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
			}
			break;
		}
		case 0x13: {
			switch(((inst) >>> (0x15)) & (0x1f)) {
				case 0x0: {
					/* MFCzanonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rt) != (0x0)) { (state.regs)[$rt] = state.copreg($cop, $rd); }
					return(true);
					break;
				}
				case 0x2: {
					/* CFCzanonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					if(($rt) != (0x0)) { (state.regs)[$rt] = state.copcreg($cop, $rd); }
					return(true);
					break;
				}
				case 0x4: {
					/* MTCzanonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					state.copreg($cop, $rd, (state.regs)[$rt]);
					return(true);
					break;
				}
				case 0x6: {
					/* CTCzanonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$rt = ((inst) >>> (0x10)) & (0x1f);
					$rd = ((inst) >>> (0xb)) & (0x1f);
					state.copcreg($cop, $rd, (state.regs)[$rt]);
					return(true);
					break;
				}
				case 0x10: {
					/* COPzanonymous_4anonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x11: {
					/* COPzanonymous_5anonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x12: {
					/* COPzanonymous_6anonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x13: {
					/* COPzanonymous_7anonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x14: {
					/* COPzanonymous_8anonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x15: {
					/* COPzanonymous_9anonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x16: {
					/* COPzanonymous_10anonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x17: {
					/* COPzanonymous_11anonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x18: {
					/* COPzanonymous_12anonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x19: {
					/* COPzanonymous_13anonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1a: {
					/* COPzanonymous_14anonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1b: {
					/* COPzanonymous_15anonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1c: {
					/* COPzanonymous_16anonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1d: {
					/* COPzanonymous_17anonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1e: {
					/* COPzanonymous_18anonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
				case 0x1f: {
					/* COPzanonymous_19anonymous_3 */
					$cop = ((inst) >>> (0x1a)) & (0x3);
					$cofun = (inst) & (0x1ffffff);
					state.copfun($cop, $cofun);
					return(true);
					break;
				}
			}
			break;
		}
		case 0x20: {
			/* LB */
			$rs = ((inst) >>> (0x15)) & (0x1f);
			$rt = ((inst) >>> (0x10)) & (0x1f);
			$imm = (inst) & (0xffff);
			$offset = signext(0x10, $imm);
			if(($rt) != (0x0)) { (state.regs)[$rt] = signext(0x8, state.mem.uint8((((state.regs)[$rs]) + ($offset)) >>> (0x0))); }
			return(true);
			break;
		}
		case 0x21: {
			/* LH */
			$rs = ((inst) >>> (0x15)) & (0x1f);
			$rt = ((inst) >>> (0x10)) & (0x1f);
			$imm = (inst) & (0xffff);
			$offset = signext(0x10, $imm);
			if(($rt) != (0x0)) { (state.regs)[$rt] = signext(0x10, state.mem.uint16((((state.regs)[$rs]) + ($offset)) >>> (0x0))); }
			return(true);
			break;
		}
		case 0x23: {
			/* LW */
			$rs = ((inst) >>> (0x15)) & (0x1f);
			$rt = ((inst) >>> (0x10)) & (0x1f);
			$imm = (inst) & (0xffff);
			$offset = signext(0x10, $imm);
			if(($rt) != (0x0)) { (state.regs)[$rt] = state.mem.uint32((((state.regs)[$rs]) + ($offset)) >>> (0x0)); }
			return(true);
			break;
		}
		case 0x24: {
			/* LBU */
			$rs = ((inst) >>> (0x15)) & (0x1f);
			$rt = ((inst) >>> (0x10)) & (0x1f);
			$imm = (inst) & (0xffff);
			$offset = signext(0x10, $imm);
			if(($rt) != (0x0)) { (state.regs)[$rt] = zeroext(0x8, state.mem.uint8((((state.regs)[$rs]) + ($offset)) >>> (0x0))); }
			return(true);
			break;
		}
		case 0x25: {
			/* LHU */
			$rs = ((inst) >>> (0x15)) & (0x1f);
			$rt = ((inst) >>> (0x10)) & (0x1f);
			$imm = (inst) & (0xffff);
			$offset = signext(0x10, $imm);
			if(($rt) != (0x0)) { (state.regs)[$rt] = zeroext(0x10, state.mem.uint16(((state.regs)[$rs]) + ($offset))); }
			return(true);
			break;
		}
		case 0x28: {
			/* SB */
			$rs = ((inst) >>> (0x15)) & (0x1f);
			$rt = ((inst) >>> (0x10)) & (0x1f);
			$imm = (inst) & (0xffff);
			$offset = signext(0x10, $imm);
			state.mem.uint8((((state.regs)[$rs]) + ($offset)) >>> (0x0), (state.regs)[$rt]);
			return(true);
			break;
		}
		case 0x29: {
			/* SH */
			$rs = ((inst) >>> (0x15)) & (0x1f);
			$rt = ((inst) >>> (0x10)) & (0x1f);
			$imm = (inst) & (0xffff);
			$offset = signext(0x10, $imm);
			state.mem.uint16((((state.regs)[$rs]) + ($offset)) >>> (0x0), (state.regs)[$rt]);
			return(true);
			break;
		}
		case 0x2b: {
			/* SW */
			$rs = ((inst) >>> (0x15)) & (0x1f);
			$rt = ((inst) >>> (0x10)) & (0x1f);
			$imm = (inst) & (0xffff);
			$offset = signext(0x10, $imm);
			state.mem.uint32((((state.regs)[$rs]) + ($offset)) >>> (0x0), (state.regs)[$rt]);
			return(true);
			break;
		}
	}
	return false;
}
